---------------------------------------------------
-- Main Units edits.
---------------------------------------------------

-- Units with chariots. Mounts in units with chariots are per-chariots, so we don't need to increase them.
WITH WITH_CHARIOTS UPDATE main_units_tables_VERSION_MAIN_UNITS AS main_units
SET
    num_men = CAST(Round(num_men * Round($0 * (SELECT_NUM_CHARIOTS)) / (SELECT_NUM_CHARIOTS), 0) AS INTEGER),
    max_men_per_ship = CAST(Round(max_men_per_ship * Round($0 * (SELECT_NUM_CHARIOTS)) / (SELECT_NUM_CHARIOTS), 0) AS INTEGER)
WHERE
    land_unit IN (SELECT key FROM chariots)
;

-- Units with mounts and no chariots.
WITH WITH_MOUNTS UPDATE main_units_tables_VERSION_MAIN_UNITS AS main_units
SET
    num_men = CAST(Round(num_men * Round($0 * (SELECT_NUM_MOUNTS)) / (SELECT_NUM_MOUNTS), 0) AS INTEGER),
    max_men_per_ship = CAST(Round(num_men * Round($0 * (SELECT_NUM_MOUNTS)) / (SELECT_NUM_MOUNTS), 0) AS INTEGER)
WHERE
    land_unit NOT IN (SELECT key FROM chariots) AND
    land_unit IN (SELECT key FROM mounts);

-- Normal units.
WITH WITH_MOUNTS UPDATE main_units_tables_VERSION_MAIN_UNITS
SET
    num_men = CAST(Round(num_men * $0, 0) AS INTEGER),
    max_men_per_ship = CAST(Round(num_men * $0, 0) AS INTEGER)
WHERE
    land_unit NOT IN (SELECT key FROM chariots) AND
    land_unit NOT IN (SELECT key FROM mounts)
;

---------------------------------------------------
-- Land Units edits.
---------------------------------------------------

-- Engine number increase.
UPDATE land_units_tables_VERSION_LAND_UNITS
SET
    num_guns = CAST(Round(num_guns * $0, 0) AS INTEGER)
WHERE (
    num_guns != 0
);

-- Mount number increase.
UPDATE land_units_tables_VERSION_LAND_UNITS
SET num_mounts = CAST(Round(num_mounts * $0, 0) AS INTEGER)
WHERE (
    num_mounts != 0 AND
    num_guns = 0
);

-- Animal number increase.
UPDATE land_units_tables_VERSION_LAND_UNITS
SET
    num_animals = CAST(Round(num_animals * $0, 0) AS INTEGER)
WHERE (
    num_animals != 0
);

-- Chariots number increase.
UPDATE land_units_tables_VERSION_LAND_UNITS
SET
    num_chariots = CAST(Round(num_chariots * $0, 0) AS INTEGER)
WHERE (
    num_chariots != 0
);


-- Rank depth increase.
UPDATE land_units_tables_VERSION_LAND_UNITS
SET rank_depth = CAST(Round(rank_depth * $0, 0) AS INTEGER)
