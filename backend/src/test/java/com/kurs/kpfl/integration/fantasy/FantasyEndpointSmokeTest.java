package com.kurs.kpfl;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.kurs.kpfl.entity.Player;
import com.kurs.kpfl.model.PlayerPosition;
import com.kurs.kpfl.repository.PlayerRepository;
import com.kurs.kpfl.repository.SeasonRepository;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.web.server.LocalServerPort;
import org.springframework.context.annotation.Import;

import java.io.IOException;
import java.math.BigDecimal;
import java.math.RoundingMode;
import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.time.LocalDateTime;
import java.util.*;
import java.util.stream.Collectors;

import static org.assertj.core.api.Assertions.assertThat;

@Import(TestcontainersConfiguration.class)
@SpringBootTest(
        webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT,
        properties = "thesportsdb.enabled=false"
)
class FantasyEndpointSmokeTest {

    @Autowired
    private PlayerRepository playerRepository;

    @Autowired
    private SeasonRepository seasonRepository;

    @LocalServerPort
    private int port;

    private final ObjectMapper objectMapper = new ObjectMapper();
    private final HttpClient httpClient = HttpClient.newHttpClient();

    @Test
    void fantasyEndpoints_shouldSupportCoreUserAndAdminFlow() throws Exception {
        String suffix = String.valueOf(System.currentTimeMillis());
        String email = "fantasy%s@kpfl.local".formatted(suffix);
        String password = "secret123";

        HttpResponse<String> register = send("POST", "/auth/register", """
                {
                  "email": "%s",
                  "password": "%s",
                  "displayName": "Fantasy User %s"
                }
                """.formatted(email, password, suffix), null);
        assertThat(register.statusCode()).isEqualTo(200);

        HttpResponse<String> login = send("POST", "/auth/login", """
                {
                  "email": "%s",
                  "password": "%s"
                }
                """.formatted(email, password), null);
        assertThat(login.statusCode()).isEqualTo(200);
        String userToken = readToken(login.body());
        String adminToken = adminToken();

        List<Player> squad = selectValidSquad();
        long seasonId = seasonRepository.findFirstByOrderByYearDesc().orElseThrow().getId();

        HttpResponse<String> createTeam = send("POST", "/me/fantasy/team", """
                {
                  "name": "Smoke Fantasy %s",
                  "playerIds": %s
                }
                """.formatted(suffix, toJsonArray(squad.stream().map(Player::getId).toList())), userToken);
        assertThat(createTeam.statusCode()).isEqualTo(200);

        HttpResponse<String> teamOverview = send("GET", "/me/fantasy/team", null, userToken);
        assertThat(teamOverview.statusCode()).isEqualTo(200);
        assertThat(objectMapper.readTree(teamOverview.body()).path("teamName").asText()).contains("Smoke Fantasy");

        List<Long> starters = buildStarters(squad);
        List<Long> bench = buildBench(squad, starters);
        Player captain = squad.stream().filter(player -> player.getId().equals(starters.get(1))).findFirst().orElseThrow();
        Player viceCaptain = squad.stream()
                .filter(player -> starters.contains(player.getId()))
                .filter(player -> !player.getClub().getId().equals(captain.getClub().getId()))
                .findFirst()
                .orElse(squad.stream().filter(player -> !player.getId().equals(captain.getId())).findFirst().orElseThrow());

        int roundNumber = 99;
        HttpResponse<String> createMatch = send("POST", "/admin/matches", """
                {
                  "seasonYear": 2026,
                  "roundNumber": %d,
                  "dateTime": "%s",
                  "stadium": "Fantasy Smoke Arena",
                  "homeClubId": %d,
                  "awayClubId": %d,
                  "status": "SCHEDULED"
                }
                """.formatted(
                        roundNumber,
                        LocalDateTime.now().plusDays(7).withNano(0),
                        captain.getClub().getId(),
                        viceCaptain.getClub().getId()
                ), adminToken);
        assertThat(createMatch.statusCode()).isEqualTo(200);
        long matchId = readId(createMatch.body());

        HttpResponse<String> saveLineup = send("PUT", "/me/fantasy/team/lineup", """
                {
                  "seasonYear": 2026,
                  "roundNumber": %d,
                  "starterPlayerIds": %s,
                  "benchPlayerIds": %s,
                  "captainPlayerId": %d,
                  "viceCaptainPlayerId": %d
                }
                """.formatted(roundNumber, toJsonArray(starters), toJsonArray(bench), captain.getId(), viceCaptain.getId()), userToken);
        assertThat(saveLineup.statusCode()).isEqualTo(200);

        HttpResponse<String> captainStats = send("POST", "/admin/fantasy/player-stats", """
                {
                  "matchId": %d,
                  "playerId": %d,
                  "minutesPlayed": 90,
                  "goals": 1,
                  "assists": 1,
                  "cleanSheet": true,
                  "goalsConceded": 0,
                  "started": true
                }
                """.formatted(matchId, captain.getId()), adminToken);
        assertThat(captainStats.statusCode()).isEqualTo(200);

        HttpResponse<String> viceStats = send("POST", "/admin/fantasy/player-stats", """
                {
                  "matchId": %d,
                  "playerId": %d,
                  "minutesPlayed": 90,
                  "goals": 1,
                  "cleanSheet": false,
                  "goalsConceded": 0,
                  "started": true
                }
                """.formatted(matchId, viceCaptain.getId()), adminToken);
        assertThat(viceStats.statusCode()).isEqualTo(200);

        HttpResponse<String> recalc = send("POST", "/admin/fantasy/recalculate/round/" + seasonId + "/" + roundNumber, null, adminToken);
        assertThat(recalc.statusCode()).isEqualTo(200);
        assertThat(objectMapper.readTree(recalc.body()).path("teamsProcessed").asInt()).isGreaterThanOrEqualTo(1);

        HttpResponse<String> roundDetails = send("GET", "/me/fantasy/team/rounds/" + roundNumber + "?seasonYear=2026", null, userToken);
        assertThat(roundDetails.statusCode()).isEqualTo(200);
        JsonNode roundJson = objectMapper.readTree(roundDetails.body());
        assertThat(roundJson.path("finalPoints").asInt()).isGreaterThan(0);
        assertThat(roundJson.path("playerPoints").isArray()).isTrue();

        HttpResponse<String> history = send("GET", "/me/fantasy/team/history?seasonYear=2026", null, userToken);
        assertThat(history.statusCode()).isEqualTo(200);
        assertThat(objectMapper.readTree(history.body()).isArray()).isTrue();

        HttpResponse<String> createLeague = send("POST", "/me/fantasy/leagues", """
                {
                  "name": "Smoke Private League %s"
                }
                """.formatted(suffix), userToken);
        assertThat(createLeague.statusCode()).isEqualTo(200);

        HttpResponse<String> myLeagues = send("GET", "/me/fantasy/leagues", null, userToken);
        assertThat(myLeagues.statusCode()).isEqualTo(200);
        assertThat(objectMapper.readTree(myLeagues.body()).isArray()).isTrue();

        HttpResponse<String> publicLeaderboard = send("GET", "/api/fantasy/leaderboard?seasonYear=2026", null, null);
        assertThat(publicLeaderboard.statusCode()).isEqualTo(200);
        assertThat(objectMapper.readTree(publicLeaderboard.body()).isArray()).isTrue();
    }

    private List<Player> selectValidSquad() {
        Map<PlayerPosition, Integer> required = new EnumMap<>(PlayerPosition.class);
        required.put(PlayerPosition.GK, 2);
        required.put(PlayerPosition.DF, 5);
        required.put(PlayerPosition.MF, 5);
        required.put(PlayerPosition.FW, 3);

        List<Player> allPlayers = playerRepository.findAll().stream()
                .sorted(Comparator.comparing(this::fantasyPrice)
                        .thenComparing(Player::getLastName)
                        .thenComparing(Player::getFirstName))
                .toList();

        List<Player> squad = new ArrayList<>();
        Map<Long, Integer> clubCounts = new HashMap<>();
        BigDecimal total = BigDecimal.ZERO;

        for (PlayerPosition position : List.of(PlayerPosition.GK, PlayerPosition.DF, PlayerPosition.MF, PlayerPosition.FW)) {
            int needed = required.get(position);
            for (Player player : allPlayers) {
                if (needed == 0) {
                    break;
                }
                if (player.getPosition() != position) {
                    continue;
                }
                if (clubCounts.getOrDefault(player.getClub().getId(), 0) >= 3) {
                    continue;
                }

                squad.add(player);
                clubCounts.merge(player.getClub().getId(), 1, Integer::sum);
                total = total.add(fantasyPrice(player));
                needed--;
            }
            assertThat(needed).as("Missing required players for " + position).isZero();
        }

        assertThat(squad).hasSize(15);
        assertThat(total).isLessThanOrEqualTo(new BigDecimal("100.0"));
        return squad;
    }

    private BigDecimal fantasyPrice(Player player) {
        BigDecimal base = switch (player.getPosition()) {
            case GK -> new BigDecimal("4.5");
            case DF -> new BigDecimal("5.0");
            case MF -> new BigDecimal("5.5");
            case FW -> new BigDecimal("6.0");
        };
        if (player.getMarketValueEur() == null) {
            return base;
        }
        BigDecimal uplift = BigDecimal.valueOf(player.getMarketValueEur())
                .divide(new BigDecimal("100000"), 4, RoundingMode.HALF_UP)
                .min(new BigDecimal("4.5"));
        return base.add(uplift).setScale(1, RoundingMode.HALF_UP);
    }

    private List<Long> buildStarters(List<Player> squad) {
        List<Long> starters = new ArrayList<>();
        starters.add(firstByPosition(squad, PlayerPosition.GK, Set.of()).getId());
        Set<Long> used = new LinkedHashSet<>(starters);
        starters.addAll(firstNByPosition(squad, PlayerPosition.DF, 3, used));
        used.addAll(starters);
        starters.addAll(firstNByPosition(squad, PlayerPosition.MF, 4, used));
        used.addAll(starters);
        starters.addAll(firstNByPosition(squad, PlayerPosition.FW, 3, used));
        return starters;
    }

    private List<Long> buildBench(List<Player> squad, List<Long> starters) {
        Set<Long> starterIds = new LinkedHashSet<>(starters);
        List<Long> bench = new ArrayList<>();
        bench.add(firstByPosition(squad, PlayerPosition.GK, starterIds).getId());
        squad.stream()
                .filter(player -> !starterIds.contains(player.getId()))
                .filter(player -> player.getPosition() != PlayerPosition.GK)
                .sorted(Comparator.comparing(Player::getPosition).thenComparing(Player::getLastName))
                .map(Player::getId)
                .forEach(bench::add);
        return bench;
    }

    private Player firstByPosition(List<Player> players, PlayerPosition position, Set<Long> excludedIds) {
        return players.stream()
                .filter(player -> player.getPosition() == position)
                .filter(player -> !excludedIds.contains(player.getId()))
                .findFirst()
                .orElseThrow();
    }

    private List<Long> firstNByPosition(List<Player> players, PlayerPosition position, int amount, Set<Long> excludedIds) {
        return players.stream()
                .filter(player -> player.getPosition() == position)
                .filter(player -> !excludedIds.contains(player.getId()))
                .limit(amount)
                .map(Player::getId)
                .toList();
    }

    private String adminToken() throws Exception {
        HttpResponse<String> login = send("POST", "/auth/login", """
                {
                  "email": "admin@kpfl.local",
                  "password": "admin"
                }
                """, null);
        assertThat(login.statusCode()).isEqualTo(200);
        return readToken(login.body());
    }

    private String toJsonArray(List<Long> values) {
        return values.stream().map(String::valueOf).collect(Collectors.joining(",", "[", "]"));
    }

    private String readToken(String body) throws Exception {
        JsonNode root = objectMapper.readTree(body);
        return root.path("token").asText();
    }

    private long readId(String body) throws Exception {
        JsonNode root = objectMapper.readTree(body);
        return root.path("id").asLong();
    }

    private HttpResponse<String> send(String method, String path, String body, String token)
            throws IOException, InterruptedException {
        HttpRequest.Builder builder = HttpRequest.newBuilder()
                .uri(URI.create("http://localhost:" + port + path))
                .header("Accept", "application/json");

        if (token != null) {
            builder.header("Authorization", "Bearer " + token);
        }

        if (body != null) {
            builder.header("Content-Type", "application/json");
            builder.method(method, HttpRequest.BodyPublishers.ofString(body));
        } else {
            builder.method(method, HttpRequest.BodyPublishers.noBody());
        }

        return httpClient.send(builder.build(), HttpResponse.BodyHandlers.ofString());
    }
}
