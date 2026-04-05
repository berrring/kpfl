package com.kurs.kpfl.service.fantasy;

import com.kurs.kpfl.model.PlayerPosition;

import java.math.BigDecimal;
import java.util.List;
import java.util.Map;

public final class FantasyRules {

    public static final BigDecimal TOTAL_BUDGET = new BigDecimal("100.0");
    public static final int MAX_PLAYERS_PER_CLUB = 3;
    public static final int FREE_TRANSFERS_PER_ROUND = 1;
    public static final int EXTRA_TRANSFER_PENALTY = 4;
    public static final int SQUAD_SIZE = 15;
    public static final int STARTERS_COUNT = 11;
    public static final int BENCH_COUNT = 4;

    public static final Map<PlayerPosition, Integer> SQUAD_LIMITS = Map.of(
            PlayerPosition.GK, 2,
            PlayerPosition.DF, 5,
            PlayerPosition.MF, 5,
            PlayerPosition.FW, 3
    );

    public static final Map<PlayerPosition, BigDecimal> DEFAULT_PRICES = Map.of(
            PlayerPosition.GK, new BigDecimal("4.5"),
            PlayerPosition.DF, new BigDecimal("5.0"),
            PlayerPosition.MF, new BigDecimal("5.5"),
            PlayerPosition.FW, new BigDecimal("6.0")
    );

    public static final List<Formation> VALID_FORMATIONS = List.of(
            new Formation(3, 4, 3),
            new Formation(3, 5, 2),
            new Formation(4, 4, 2),
            new Formation(4, 3, 3),
            new Formation(4, 5, 1),
            new Formation(5, 4, 1),
            new Formation(5, 3, 2)
    );

    private FantasyRules() {
    }

    public static boolean isValidFormation(long defenders, long midfielders, long forwards) {
        return VALID_FORMATIONS.stream().anyMatch(formation -> formation.matches(defenders, midfielders, forwards));
    }

    public static boolean canExtendToValidFormation(long defenders, long midfielders, long forwards) {
        return VALID_FORMATIONS.stream().anyMatch(formation -> formation.canExtend(defenders, midfielders, forwards));
    }

    public static int goalPoints(PlayerPosition position) {
        return switch (position) {
            case GK -> 10;
            case DF -> 6;
            case MF -> 5;
            case FW -> 4;
        };
    }

    public static int cleanSheetPoints(PlayerPosition position) {
        return switch (position) {
            case GK, DF -> 4;
            case MF -> 1;
            case FW -> 0;
        };
    }

    public record Formation(int defenders, int midfielders, int forwards) {
        boolean matches(long currentDefenders, long currentMidfielders, long currentForwards) {
            return defenders == currentDefenders && midfielders == currentMidfielders && forwards == currentForwards;
        }

        boolean canExtend(long currentDefenders, long currentMidfielders, long currentForwards) {
            return currentDefenders <= defenders && currentMidfielders <= midfielders && currentForwards <= forwards;
        }
    }
}
