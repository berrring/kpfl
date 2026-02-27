package com.kurs.kpfl;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.kurs.kpfl.entity.Club;
import com.kurs.kpfl.entity.Match;
import com.kurs.kpfl.entity.News;
import com.kurs.kpfl.entity.Player;
import com.kurs.kpfl.repository.ClubRepository;
import com.kurs.kpfl.repository.MatchRepository;
import com.kurs.kpfl.repository.NewsRepository;
import com.kurs.kpfl.repository.PlayerRepository;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.web.server.LocalServerPort;
import org.springframework.context.annotation.Import;

import java.io.IOException;
import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.time.LocalDateTime;

import static org.assertj.core.api.Assertions.assertThat;

@Import(TestcontainersConfiguration.class)
@SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT)
class EndpointSmokeTest {

    @Autowired
    private ClubRepository clubRepository;

    @Autowired
    private PlayerRepository playerRepository;

    @Autowired
    private MatchRepository matchRepository;

    @Autowired
    private NewsRepository newsRepository;

    @LocalServerPort
    private int port;

    private final ObjectMapper objectMapper = new ObjectMapper();
    private final HttpClient httpClient = HttpClient.newHttpClient();

    @Test
    void publicEndpoints_shouldReturnData() throws Exception {
        Club club = clubRepository.findAll().stream().findFirst().orElseThrow();
        Player player = playerRepository.findAll().stream().findFirst().orElseThrow();
        Match match = matchRepository.findAll().stream().findFirst().orElseThrow();
        News news = newsRepository.findAll().stream().findFirst().orElseThrow();

        HttpResponse<String> clubs = send("GET", "/api/clubs", null, null);
        assertThat(clubs.statusCode()).isEqualTo(200);
        assertThat(objectMapper.readTree(clubs.body()).isArray()).isTrue();

        HttpResponse<String> clubById = send("GET", "/api/clubs/" + club.getId(), null, null);
        assertThat(clubById.statusCode()).isEqualTo(200);
        assertThat(readId(clubById.body())).isEqualTo(club.getId());

        HttpResponse<String> playerById = send("GET", "/api/players/" + player.getId(), null, null);
        assertThat(playerById.statusCode()).isEqualTo(200);
        assertThat(readId(playerById.body())).isEqualTo(player.getId());

        HttpResponse<String> matchesFiltered = send("GET", "/api/matches?seasonYear=2026&round=1&status=FINISHED", null, null);
        assertThat(matchesFiltered.statusCode()).isEqualTo(200);
        assertThat(objectMapper.readTree(matchesFiltered.body()).isArray()).isTrue();

        HttpResponse<String> matchById = send("GET", "/api/matches/" + match.getId(), null, null);
        assertThat(matchById.statusCode()).isEqualTo(200);
        assertThat(readId(matchById.body())).isEqualTo(match.getId());

        HttpResponse<String> standings = send("GET", "/api/standings?seasonYear=2026", null, null);
        assertThat(standings.statusCode()).isEqualTo(200);
        assertThat(objectMapper.readTree(standings.body()).isArray()).isTrue();

        HttpResponse<String> newsList = send("GET", "/api/news?limit=5", null, null);
        assertThat(newsList.statusCode()).isEqualTo(200);
        assertThat(objectMapper.readTree(newsList.body()).isArray()).isTrue();

        HttpResponse<String> newsById = send("GET", "/api/news/" + news.getId(), null, null);
        assertThat(newsById.statusCode()).isEqualTo(200);
        assertThat(readId(newsById.body())).isEqualTo(news.getId());
    }

    @Test
    void authEndpoints_shouldWorkForRegisterAndLogin() throws Exception {
        String suffix = String.valueOf(System.currentTimeMillis());

        HttpResponse<String> register = send("POST", "/auth/register", """
                {
                  "email": "user%s@kpfl.local",
                  "password": "secret123",
                  "displayName": "Smoke User %s"
                }
                """.formatted(suffix, suffix), null);
        assertThat(register.statusCode()).isEqualTo(200);
        assertThat(readToken(register.body())).isNotBlank();

        HttpResponse<String> login = send("POST", "/auth/login", """
                {
                  "email": "admin@kpfl.local",
                  "password": "admin"
                }
                """, null);
        assertThat(login.statusCode()).isEqualTo(200);
        assertThat(readToken(login.body())).isNotBlank();
    }

    @Test
    void adminEndpoints_shouldRejectUnauthenticatedRequests() throws Exception {
        HttpResponse<String> unauthorized = send("POST", "/admin/clubs", """
                {
                  "name": "No Auth Club",
                  "abbr": "NAC",
                  "city": "Bishkek"
                }
                """, null);
        assertThat(unauthorized.statusCode()).isIn(401, 403);
    }

    @Test
    void adminEndpoints_shouldSupportCreateAndUpdateFlow() throws Exception {
        String token = adminToken();
        Long existingClubId = clubRepository.findAll().stream().findFirst().orElseThrow().getId();
        String suffix = String.valueOf(System.nanoTime() % 1000000);
        String newAbbr = "S" + suffix.substring(0, Math.min(6, suffix.length()));
        String updatedAbbr = "U" + suffix.substring(0, Math.min(6, suffix.length()));

        HttpResponse<String> createClub = send("POST", "/admin/clubs", """
                {
                  "name": "Smoke Club %s",
                  "abbr": "%s",
                  "city": "Bishkek",
                  "stadium": "Smoke Arena",
                  "foundedYear": 2026,
                  "primaryColor": "#123456",
                  "coachName": "Coach Smoke",
                  "coachInfo": "Smoke test coach"
                }
                """.formatted(suffix, newAbbr), token);
        assertThat(createClub.statusCode()).isEqualTo(200);
        long createdClubId = readId(createClub.body());

        HttpResponse<String> updateClub = send("PUT", "/admin/clubs/" + createdClubId, """
                {
                  "name": "Smoke Club %s Updated",
                  "abbr": "%s",
                  "city": "Osh",
                  "stadium": "Updated Arena",
                  "foundedYear": 2027,
                  "primaryColor": "#654321",
                  "coachName": "Coach Updated",
                  "coachInfo": "Updated coach info"
                }
                """.formatted(suffix, updatedAbbr), token);
        assertThat(updateClub.statusCode()).isEqualTo(200);
        assertThat(readId(updateClub.body())).isEqualTo(createdClubId);

        HttpResponse<String> createPlayer = send("POST", "/admin/players", """
                {
                  "clubId": %d,
                  "firstName": "Smoke",
                  "lastName": "Player %s",
                  "number": 99,
                  "position": "FW",
                  "ageYears": 22,
                  "marketValueEur": 50000,
                  "sourceUrl": "https://example.com/smoke",
                  "sourceNote": "smoke create"
                }
                """.formatted(createdClubId, suffix), token);
        assertThat(createPlayer.statusCode()).isEqualTo(200);
        long createdPlayerId = readId(createPlayer.body());

        HttpResponse<String> updatePlayer = send("PUT", "/admin/players/" + createdPlayerId, """
                {
                  "clubId": %d,
                  "firstName": "Smoke",
                  "lastName": "Player %s Updated",
                  "number": 77,
                  "position": "MF",
                  "ageYears": 23,
                  "marketValueEur": 70000,
                  "sourceUrl": "https://example.com/smoke-updated",
                  "sourceNote": "smoke update"
                }
                """.formatted(createdClubId, suffix), token);
        assertThat(updatePlayer.statusCode()).isEqualTo(200);
        assertThat(readId(updatePlayer.body())).isEqualTo(createdPlayerId);

        Long awayClubId = clubRepository.findAll().stream()
                .map(Club::getId)
                .filter(id -> !id.equals(createdClubId))
                .findFirst()
                .orElse(existingClubId);

        HttpResponse<String> createMatch = send("POST", "/admin/matches", """
                {
                  "seasonYear": 2027,
                  "roundNumber": 3,
                  "dateTime": "%s",
                  "stadium": "Smoke Arena",
                  "homeClubId": %d,
                  "awayClubId": %d,
                  "status": "SCHEDULED"
                }
                """.formatted(LocalDateTime.now().plusDays(5).withNano(0), createdClubId, awayClubId), token);
        assertThat(createMatch.statusCode()).isEqualTo(200);
        long createdMatchId = readId(createMatch.body());

        HttpResponse<String> updateMatch = send("PUT", "/admin/matches/" + createdMatchId, """
                {
                  "seasonYear": 2027,
                  "roundNumber": 4,
                  "dateTime": "%s",
                  "stadium": "Smoke Arena 2",
                  "homeClubId": %d,
                  "awayClubId": %d,
                  "status": "SCHEDULED"
                }
                """.formatted(LocalDateTime.now().plusDays(7).withNano(0), createdClubId, awayClubId), token);
        assertThat(updateMatch.statusCode()).isEqualTo(200);
        assertThat(readId(updateMatch.body())).isEqualTo(createdMatchId);

        HttpResponse<String> setResult = send("POST", "/admin/matches/" + createdMatchId + "/result", """
                {
                  "homeGoals": 2,
                  "awayGoals": 1
                }
                """, token);
        assertThat(setResult.statusCode()).isEqualTo(200);
        JsonNode setResultJson = objectMapper.readTree(setResult.body());
        assertThat(setResultJson.path("id").asLong()).isEqualTo(createdMatchId);
        assertThat(setResultJson.path("status").asText()).isEqualTo("FINISHED");

        HttpResponse<String> createNews = send("POST", "/admin/news", """
                {
                  "title": "Smoke News %s",
                  "shortText": "Smoke create news",
                  "tag": "OFFICIAL",
                  "publishedAt": "%s",
                  "clubId": %d,
                  "playerId": %d
                }
                """.formatted(suffix, LocalDateTime.now().withNano(0), createdClubId, createdPlayerId), token);
        assertThat(createNews.statusCode()).isEqualTo(200);
        long createdNewsId = readId(createNews.body());

        HttpResponse<String> updateNews = send("PUT", "/admin/news/" + createdNewsId, """
                {
                  "title": "Smoke News %s Updated",
                  "shortText": "Smoke update news",
                  "tag": "MATCHDAY",
                  "publishedAt": "%s",
                  "clubId": %d,
                  "playerId": %d
                }
                """.formatted(suffix, LocalDateTime.now().plusHours(1).withNano(0), createdClubId, createdPlayerId), token);
        assertThat(updateNews.statusCode()).isEqualTo(200);
        assertThat(readId(updateNews.body())).isEqualTo(createdNewsId);
    }

    private String adminToken() throws Exception {
        HttpResponse<String> login = send("POST", "/auth/login", """
                {
                  "email": "admin@kpfl.local",
                  "password": "admin"
                }
                """, null);
        assertThat(login.statusCode()).isEqualTo(200);
        String token = readToken(login.body());
        assertThat(token).isNotBlank();
        return token;
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
