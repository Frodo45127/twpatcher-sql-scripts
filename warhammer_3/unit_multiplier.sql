-- Scaling for different things that rely on unit size.
UPDATE _kv_rules_tables_VERSION__KV_RULES
SET value = value * $0
WHERE key IN (
    'unit_max_drag_width',
    'realm_of_souls_tier_1_death_threshold',
    'realm_of_souls_tier_2_death_threshold',
    'realm_of_souls_tier_3_death_threshold',
    'unit_tier1_kills',
    'unit_tier2_kills',
    'unit_tier3_kills',
    'waaagh_base_threshold'
);

-- Damage scaling.
UPDATE _kv_unit_ability_scaling_rules_tables_VERSION__KV_UNIT_ABILITY_SCALING_RULES
SET value = value * $0
WHERE key IN (
    'direct_damage_large',
    'direct_damage_medium',
    'direct_damage_small',
    'direct_damage_ultra'
);

-- Generic stat scaling by battle and size.
UPDATE unit_size_global_scalings_tables_VERSION_UNIT_SIZE_GLOBAL_SCALINGS
SET (
    hit_points_building_small,
    hit_points_building_medium,
    hit_points_building_large,
    hit_points_building_ultra,
    hit_points_siege_vehicle_small,
    hit_points_siege_vehicle_medium,
    hit_points_siege_vehicle_large,
    hit_points_siege_vehicle_ultra,
    building_projectile_damage_small,
    building_projectile_damage_medium,
    building_projectile_damage_large,
    building_projectile_damage_ultra,
    building_projectile_detonation_damage_small,
    building_projectile_detonation_damage_medium,
    building_projectile_detonation_damage_large,
    building_projectile_detonation_damage_ultra,
    fort_tower_fire_frequency_small,
    fort_tower_fire_frequency_medium,
    fort_tower_fire_frequency_large,
    fort_tower_fire_frequency_ultra
) = (
    hit_points_building_small * $0,
    hit_points_building_medium * $0,
    hit_points_building_large * $0,
    hit_points_building_ultra * $0,
    hit_points_siege_vehicle_small * $0,
    hit_points_siege_vehicle_medium * $0,
    hit_points_siege_vehicle_large * $0,
    hit_points_siege_vehicle_ultra * $0,
    building_projectile_damage_small * $0,
    building_projectile_damage_medium * $0,
    building_projectile_damage_large * $0,
    building_projectile_damage_ultra * $0,
    building_projectile_detonation_damage_small * $0,
    building_projectile_detonation_damage_medium * $0,
    building_projectile_detonation_damage_large * $0,
    building_projectile_detonation_damage_ultra * $0,
    fort_tower_fire_frequency_small * $0,
    fort_tower_fire_frequency_medium * $0,
    fort_tower_fire_frequency_large * $0,
    fort_tower_fire_frequency_ultra * $0
);

-- Generic stat scaling by size.
UPDATE unit_stat_to_size_scaling_values_tables_VERSION_UNIT_STAT_TO_SIZE_SCALING_VALUES
SET single_entity_value = single_entity_value * $0;

---------------------------------------------------
-- Main Units edits.
---------------------------------------------------

-- Units with engines. Mounts in units with engines are per-engine, so we don't need to increase them.
WITH WITH_SINGLE_ENTITIES, WITH_ENGINES UPDATE main_units_tables_VERSION_MAIN_UNITS AS main_units
SET num_men = CAST(Round(num_men * Round($0 * (SELECT_NUM_ENGINES)) / (SELECT_NUM_ENGINES), 0) AS INTEGER)
WHERE
    unit NOT IN (SELECT unit FROM single_entities) AND
    land_unit IN (SELECT key FROM engines)
;

-- Units with mounts and no engines.
WITH WITH_SINGLE_ENTITIES, WITH_MOUNTS UPDATE main_units_tables_VERSION_MAIN_UNITS AS main_units
SET num_men = CAST(Round(num_men * Round($0 * (SELECT_NUM_MOUNTS)) / (SELECT_NUM_MOUNTS), 0) AS INTEGER)
WHERE
    unit NOT IN (SELECT unit FROM single_entities) AND
    land_unit NOT IN (SELECT key FROM engines) AND
    land_unit IN (SELECT key FROM mounts);

-- Normal units.
WITH WITH_SINGLE_ENTITIES, WITH_MOUNTS UPDATE main_units_tables_VERSION_MAIN_UNITS
SET num_men = CAST(Round(num_men * $0, 0) AS INTEGER)
WHERE
    unit NOT IN (SELECT unit FROM single_entities) AND
    land_unit NOT IN (SELECT key FROM engines) AND
    land_unit NOT IN (SELECT key FROM mounts)
;

---------------------------------------------------
-- Land Units edits.
---------------------------------------------------

-- Engine number increase.
WITH WITH_SINGLE_ENTITIES UPDATE land_units_tables_VERSION_LAND_UNITS
SET num_engines = CAST(Round(num_engines * $0, 0) AS INTEGER)
WHERE (
    num_engines != 0 AND
    key NOT IN (SELECT land_unit FROM single_entities)
);

-- Mount number increase.
WITH WITH_SINGLE_ENTITIES UPDATE land_units_tables_VERSION_LAND_UNITS
SET num_mounts = CAST(Round(num_mounts * $0, 0) AS INTEGER)
WHERE (
    num_mounts != 0 AND
    num_engines = 0 AND
    key NOT IN (SELECT land_unit FROM single_entities)
);

-- Rank depth increase.
WITH WITH_SINGLE_ENTITIES UPDATE land_units_tables_VERSION_LAND_UNITS
SET rank_depth = CAST(Round(rank_depth * $0, 0) AS INTEGER)
WHERE key NOT IN (SELECT land_unit FROM single_entities);

-- Single entities health increase.
WITH WITH_SINGLE_ENTITIES UPDATE land_units_tables_VERSION_LAND_UNITS
SET bonus_hit_points = CAST(Round(bonus_hit_points * $0, 0) AS INTEGER)
WHERE key IN (SELECT land_unit FROM single_entities);
