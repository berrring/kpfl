package com.kurs.kpfl.service.fantasy;

import com.kurs.kpfl.dto.fantasy.FantasyLineupPlayerDto;
import com.kurs.kpfl.dto.fantasy.FantasyLineupUpdateRequest;
import com.kurs.kpfl.entity.Player;
import com.kurs.kpfl.entity.Season;
import com.kurs.kpfl.entity.fantasy.FantasyTeam;
import com.kurs.kpfl.entity.fantasy.FantasyTeamRoundSelection;

import java.util.List;
import java.util.Map;

public interface FantasySelectionService {
    FantasyTeamRoundSelection getOrCreateSelection(FantasyTeam fantasyTeam, Season season, Integer roundNumber);
    FantasyTeamRoundSelection rebuildDefaultSelection(FantasyTeam fantasyTeam, Season season, Integer roundNumber, List<Player> squadPlayers);
    FantasyTeamRoundSelection saveSelection(
            FantasyTeam fantasyTeam,
            Season season,
            FantasyLineupUpdateRequest request,
            Map<Long, Player> activePlayers
    );
    List<FantasyLineupPlayerDto> mapLineup(FantasyTeamRoundSelection selection);
}
