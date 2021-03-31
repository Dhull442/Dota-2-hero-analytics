-- public.ability_ids definition

-- Drop table

-- DROP TABLE public.ability_ids;

CREATE TABLE public.ability_ids (
	ability_id numeric NOT NULL,
	ability_name text NULL,
	CONSTRAINT ability_ids_pk PRIMARY KEY (ability_id)
);
CREATE INDEX ability_indx_2 ON public.ability_ids USING btree (ability_id);

-- public.ability_upgrades definition

-- Drop table

-- DROP TABLE public.ability_upgrades;

CREATE TABLE public.ability_upgrades (
	ability numeric NULL,
	"level" numeric NOT NULL,
	"time" numeric NULL,
	player_slot numeric NOT NULL,
	match_id numeric NOT NULL,
	CONSTRAINT ability_upgrades_pk PRIMARY KEY (match_id, player_slot, level)
);
CREATE INDEX ability_upgarde_indx_2 ON public.ability_upgrades USING btree (match_id, player_slot);


-- public.ability_upgrades foreign keys

ALTER TABLE public.ability_upgrades ADD CONSTRAINT ability_upgrades_fk FOREIGN KEY (match_id) REFERENCES public."match"(match_id) ON DELETE SET NULL ON UPDATE CASCADE;
ALTER TABLE public.ability_upgrades ADD CONSTRAINT ability_upgrades_fk_1 FOREIGN KEY (ability) REFERENCES public.ability_ids(ability_id) ON DELETE SET NULL ON UPDATE CASCADE;

-- public.cluster_regions definition

-- Drop table

-- DROP TABLE public.cluster_regions;

CREATE TABLE public.cluster_regions (
	"cluster" numeric NOT NULL,
	region text NULL,
	CONSTRAINT cluster_regions_pk PRIMARY KEY (cluster)
);

-- public.hero_names definition

-- Drop table

-- DROP TABLE public.hero_names;

CREATE TABLE public.hero_names (
	"name" text NULL,
	hero_id numeric NOT NULL,
	localized_name text NULL,
	CONSTRAINT hero_names_pk PRIMARY KEY (hero_id)
);
CREATE INDEX hero_names_indx ON public.hero_names USING btree (hero_id);

-- public.item_ids definition

-- Drop table

-- DROP TABLE public.item_ids;

CREATE TABLE public.item_ids (
	item_id numeric NOT NULL,
	item_name text NULL,
	CONSTRAINT item_ids_pk PRIMARY KEY (item_id)
);

-- public."match" definition

-- Drop table

-- DROP TABLE public."match";

CREATE TABLE public."match" (
	match_id numeric NOT NULL,
	start_time numeric NULL,
	duration numeric NULL,
	tower_status_radiant numeric NULL,
	tower_status_dire numeric NULL,
	barracks_status_dire numeric NULL,
	barracks_status_radiant numeric NULL,
	first_blood_time numeric NULL,
	game_mode numeric NULL,
	radiant_win text NULL,
	negative_votes numeric NULL,
	positive_votes numeric NULL,
	"cluster" numeric NULL,
	CONSTRAINT match_pk PRIMARY KEY (match_id)
);
CREATE INDEX match_indx ON public.match USING btree (match_id);


-- public.match_outcomes definition

-- Drop table

-- DROP TABLE public.match_outcomes;

CREATE TABLE public.match_outcomes (
	match_id numeric NULL,
	account_id_0 numeric NULL,
	account_id_1 numeric NULL,
	account_id_2 numeric NULL,
	account_id_3 numeric NULL,
	account_id_4 numeric NULL,
	start_time numeric NULL,
	parser_version numeric NULL,
	win numeric NULL,
	rad numeric NULL
);

-- public.objectives definition

-- Drop table

-- DROP TABLE public.objectives;

CREATE TABLE public.objectives (
	match_id numeric NULL,
	"key" text NULL,
	player1 numeric NULL,
	player2 numeric NULL,
	slot text NULL,
	subtype text NULL,
	team text NULL,
	"time" numeric NULL,
	value numeric NULL
);

-- public.patch_dates definition

-- Drop table

-- DROP TABLE public.patch_dates;

CREATE TABLE public.patch_dates (
	patch_date text NULL,
	"name" numeric NULL
);


-- public.player_ratings definition

-- Drop table

-- DROP TABLE public.player_ratings;

CREATE TABLE public.player_ratings (
	account_id numeric NULL,
	total_wins numeric NULL,
	total_matches numeric NULL,
	trueskill_mu numeric NULL,
	trueskill_sigma numeric NULL
);

-- public.player_time definition

-- Drop table

-- DROP TABLE public.player_time;

CREATE TABLE public.player_time (
	match_id numeric NOT NULL,
	times numeric NOT NULL,
	gold_t_0 numeric NULL,
	lh_t_0 numeric NULL,
	xp_t_0 numeric NULL,
	gold_t_1 numeric NULL,
	lh_t_1 numeric NULL,
	xp_t_1 numeric NULL,
	gold_t_2 numeric NULL,
	lh_t_2 numeric NULL,
	xp_t_2 numeric NULL,
	gold_t_3 numeric NULL,
	lh_t_3 numeric NULL,
	xp_t_3 numeric NULL,
	gold_t_4 numeric NULL,
	lh_t_4 numeric NULL,
	xp_t_4 numeric NULL,
	gold_t_128 numeric NULL,
	lh_t_128 numeric NULL,
	xp_t_128 numeric NULL,
	gold_t_129 numeric NULL,
	lh_t_129 numeric NULL,
	xp_t_129 numeric NULL,
	gold_t_130 numeric NULL,
	lh_t_130 numeric NULL,
	xp_t_130 numeric NULL,
	gold_t_131 numeric NULL,
	lh_t_131 numeric NULL,
	xp_t_131 numeric NULL,
	gold_t_132 numeric NULL,
	lh_t_132 numeric NULL,
	xp_t_132 numeric NULL,
	CONSTRAINT player_time_pk PRIMARY KEY (match_id, times)
);


-- public.player_time foreign keys

ALTER TABLE public.player_time ADD CONSTRAINT player_time_fk FOREIGN KEY (match_id) REFERENCES public."match"(match_id) ON DELETE SET NULL ON UPDATE CASCADE;


-- public.players definition

-- Drop table

-- DROP TABLE public.players;

CREATE TABLE public.players (
	match_id numeric NOT NULL,
	account_id numeric NULL,
	hero_id numeric NULL,
	player_slot numeric NOT NULL,
	gold numeric NULL,
	gold_spent numeric NULL,
	gold_per_min numeric NULL,
	xp_per_min numeric NULL,
	kills numeric NULL,
	deaths numeric NULL,
	assists numeric NULL,
	denies numeric NULL,
	last_hits numeric NULL,
	stuns text NULL,
	hero_damage numeric NULL,
	hero_healing numeric NULL,
	tower_damage numeric NULL,
	item_0 numeric NULL,
	item_1 numeric NULL,
	item_2 numeric NULL,
	item_3 numeric NULL,
	item_4 numeric NULL,
	item_5 numeric NULL,
	"level" numeric NULL,
	leaver_status numeric NULL,
	xp_hero numeric NULL,
	xp_creep numeric NULL,
	xp_roshan numeric NULL,
	xp_other numeric NULL,
	gold_other numeric NULL,
	gold_death numeric NULL,
	gold_buyback numeric NULL,
	gold_abandon numeric NULL,
	gold_sell numeric NULL,
	gold_destroying_structure numeric NULL,
	gold_killing_heros numeric NULL,
	gold_killing_creeps numeric NULL,
	gold_killing_roshan numeric NULL,
	gold_killing_couriers numeric NULL,
	unit_order_none text NULL,
	unit_order_move_to_position numeric NULL,
	unit_order_move_to_target numeric NULL,
	unit_order_attack_move numeric NULL,
	unit_order_attack_target numeric NULL,
	unit_order_cast_position numeric NULL,
	unit_order_cast_target numeric NULL,
	unit_order_cast_target_tree numeric NULL,
	unit_order_cast_no_target numeric NULL,
	unit_order_cast_toggle numeric NULL,
	unit_order_hold_position numeric NULL,
	unit_order_train_ability numeric NULL,
	unit_order_drop_item numeric NULL,
	unit_order_give_item numeric NULL,
	unit_order_pickup_item numeric NULL,
	unit_order_pickup_rune numeric NULL,
	unit_order_purchase_item numeric NULL,
	unit_order_sell_item numeric NULL,
	unit_order_disassemble_item numeric NULL,
	unit_order_move_item numeric NULL,
	unit_order_cast_toggle_auto numeric NULL,
	unit_order_stop numeric NULL,
	unit_order_taunt text NULL,
	unit_order_buyback numeric NULL,
	unit_order_glyph numeric NULL,
	unit_order_eject_item_from_stash numeric NULL,
	unit_order_cast_rune text NULL,
	unit_order_ping_ability numeric NULL,
	unit_order_move_to_direction numeric NULL,
	unit_order_patrol text NULL,
	unit_order_vector_target_position text NULL,
	unit_order_radar text NULL,
	unit_order_set_item_combine_lock text NULL,
	unit_order_continue text NULL,
	CONSTRAINT players_pk PRIMARY KEY (match_id, player_slot)
);
CREATE INDEX player_indx ON public.players USING btree (hero_id);
CREATE INDEX player_indx_2 ON public.players USING btree (match_id, player_slot);

-- public.players foreign keys

ALTER TABLE public.players ADD CONSTRAINT players_fk FOREIGN KEY (match_id) REFERENCES public."match"(match_id) ON DELETE SET NULL ON UPDATE CASCADE;


-- public.purchase_log definition

-- Drop table

-- DROP TABLE public.purchase_log;

CREATE TABLE public.purchase_log (
	item_id numeric NULL,
	"time" numeric NULL,
	player_slot numeric NULL,
	match_id numeric NULL
);
CREATE INDEX purchase_indx ON public.purchase_log USING btree (match_id);

-- public.purchase_log foreign keys

ALTER TABLE public.purchase_log ADD CONSTRAINT purchase_log_fk FOREIGN KEY (item_id) REFERENCES public.item_ids(item_id) ON DELETE SET NULL ON UPDATE CASCADE;
ALTER TABLE public.purchase_log ADD CONSTRAINT purchase_log_fk_1 FOREIGN KEY (match_id) REFERENCES public."match"(match_id) ON DELETE SET NULL ON UPDATE CASCADE;

-- public.teamfights definition

-- Drop table

-- DROP TABLE public.teamfights;

CREATE TABLE public.teamfights (
	match_id numeric NOT NULL,
	"start" numeric NOT NULL,
	"end" numeric NOT NULL,
	last_death numeric NULL,
	deaths numeric NULL,
	CONSTRAINT teamfights_pk PRIMARY KEY (match_id, start, "end")
);


-- public.teamfights foreign keys

ALTER TABLE public.teamfights ADD CONSTRAINT teamfights_fk FOREIGN KEY (match_id) REFERENCES public."match"(match_id) ON DELETE SET NULL ON UPDATE CASCADE;

-- public.teamfights_players definition

-- Drop table

-- DROP TABLE public.teamfights_players;

CREATE TABLE public.teamfights_players (
	match_id numeric NULL,
	player_slot numeric NULL,
	buybacks numeric NULL,
	damage numeric NULL,
	deaths numeric NULL,
	gold_delta numeric NULL,
	xp_end numeric NULL,
	xp_start numeric NULL
);


-- public.teamfights_players foreign keys

ALTER TABLE public.teamfights_players ADD CONSTRAINT teamfights_players_fk FOREIGN KEY (match_id) REFERENCES public."match"(match_id) ON DELETE SET NULL ON UPDATE CASCADE;

-- public.test_labels definition

-- Drop table

-- DROP TABLE public.test_labels;

CREATE TABLE public.test_labels (
	match_id numeric NULL,
	radiant_win numeric NULL
);

-- public.test_player definition

-- Drop table

-- DROP TABLE public.test_player;

CREATE TABLE public.test_player (
	match_id numeric NULL,
	account_id numeric NULL,
	hero_id numeric NULL,
	player_slot numeric NULL
);


--load from csvs
copy ability_ids from '/media/jay/7E5662245661DE01/sem8/DBMS/project/archive/ability_ids.csv' delimiter ',' CSV HEADER;
copy ability_upgrades from '/media/jay/7E5662245661DE01/sem8/DBMS/project/archive/ability_upgrades.csv' delimiter ',' CSV HEADER;
copy cluster_regions from '/media/jay/7E5662245661DE01/sem8/DBMS/project/archive/cluster_regions.csv' delimiter ',' CSV HEADER;
copy hero_names from '/media/jay/7E5662245661DE01/sem8/DBMS/project/archive/hero_names.csv' delimiter ',' CSV HEADER;
copy item_ids from '/media/jay/7E5662245661DE01/sem8/DBMS/project/archive/item_ids.csv' delimiter ',' CSV HEADER;
copy match from '/media/jay/7E5662245661DE01/sem8/DBMS/project/archive/match.csv' delimiter ',' CSV HEADER;
copy match_outcomes from '/media/jay/7E5662245661DE01/sem8/DBMS/project/archive/match_outcomes.csv' delimiter ',' CSV HEADER;
copy objectives from '/media/jay/7E5662245661DE01/sem8/DBMS/project/archive/objectives.csv' delimiter ',' CSV HEADER;
copy patch_dates from '/media/jay/7E5662245661DE01/sem8/DBMS/project/archive/patch_dates.csv' delimiter ',' CSV HEADER;
copy player_ratings from '/media/jay/7E5662245661DE01/sem8/DBMS/project/archive/player_ratings.csv' delimiter ',' CSV HEADER;
copy players from '/media/jay/7E5662245661DE01/sem8/DBMS/project/archive/players.csv' delimiter ',' CSV HEADER;
copy player_time from '/media/jay/7E5662245661DE01/sem8/DBMS/project/archive/player_time.csv' delimiter ',' CSV HEADER;
copy purchase_log from '/media/jay/7E5662245661DE01/sem8/DBMS/project/archive/purchase_log.csv' delimiter ',' CSV HEADER;
copy teamfights from '/media/jay/7E5662245661DE01/sem8/DBMS/project/archive/teamfights.csv' delimiter ',' CSV HEADER;
copy teamfights_players from '/media/jay/7E5662245661DE01/sem8/DBMS/project/archive/teamfights_players.csv' delimiter ',' CSV HEADER;
copy test_labels from '/media/jay/7E5662245661DE01/sem8/DBMS/project/archive/test_labels.csv' delimiter ',' CSV HEADER;
copy test_player from '/media/jay/7E5662245661DE01/sem8/DBMS/project/archive/test_player.csv' delimiter ',' CSV HEADER;
