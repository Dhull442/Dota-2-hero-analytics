from flask import Flask, render_template, request
import psycopg2 as pg


# Queries Dictionary
qdict = {
    "gq1":(["Hero Name"],"select min as hero_name from ( select min(localized_name), count(1) from players inner join hero_names using(hero_id) group by hero_id order by count desc limit 10 ) foo;"),
    "gq3":(["Percentage of Radiant Wins"],   "select round(100*(numerator.count/num_matches.num_matches ),2)as radiant_wins from\
                                            num_matches,\
                                            (\
                                                select count(1) from match\
                                                where radiant_win = 'True'\
                                            ) numerator\
                                            ;"),
    "gq4":(["Percentage of Dire Wins"],   "select round(100 - 100*(numerator.count/num_matches.num_matches ),2)as radiant_wins from\
                                            num_matches,\
                                            (\
                                                select count(1) from match\
                                                where radiant_win = 'True'\
                                            ) numerator\
                                            ;"),

    "hq1":(["Hero Name","Number of Matches","Pick Rate","Win Rate", "KDA"],\
            "select hero_name, count(1) as num_matches_played, round(100*(count(1)/min(num_matches)),2) as pick_rate, \
            round(100*(sum(won::int)/cast(count(1) as decimal)),2) as win_rate,\
            round((avg(K)+avg(A))/cast(avg(D) as decimal),2) as KDA\
            from player_hero_wins, num_matches\
            group by hero_name\
            order by pick_rate desc, win_rate desc, hero_name\
        ;"),

    "hq2":(["Hero Name","Win Rate","Pick Rate", "KDA"],\
            "select hero_name, \
            round(100*(sum(won::int)/cast(count(1) as decimal)),2) as win_rate,\
            round(100*(count(1)/min(num_matches)),2) as pick_rate,\
            round((avg(K)+avg(A))/cast(avg(D) as decimal),2) as KDA\
            from player_hero_wins, num_matches\
            group by hero_name\
            order by win_rate desc, pick_rate desc, hero_name\
            ;"
    ),

    "hq3":(
        ["Hero Name", "KDA", "Kills", "Deaths", "Assists"],\
        "select hero_name, \
        round((avg(K)+avg(A))/cast(avg(D) as decimal),2) as KDA,\
        round(avg(K),2) as K,\
        round(avg(D),2) as D,\
        round(avg(A),2) as A\
        from player_hero_wins, num_matches\
        group by hero_name\
        order by KDA desc, hero_name\
        ;"
    ),

    "hq4":(
        ["Hero Name","Gold Per Minute","Experience Per Minute"],\
        'select hero_name, round(avg(gpm),2) as "Gold / Minute", round(avg(xppm),2) as "Experience / Minute"\
        from player_hero_wins\
        group by hero_name\
        order by "Gold / Minute" desc, "Experience / Minute" desc,hero_name\
        ;'
    ),

    "hq5":(
        ["Hero Name","Average Damage","Average Tower Damage","Average Healing"],\
        'select hero_name, round(avg(damage),2) as "Average Damage", round(avg(tower_damage),2) as "Average Tower Damage",\
        round(avg(healing),2) as "Average Healing"\
        from player_hero_wins\
        group by hero_name\
        order by "Average Damage" desc, "Average Tower Damage" desc, "Average Healing" desc, hero_name\
        ;'
    ),

    "hq6":(
        ["Hero Name"],\
        'select localized_name as name from hero_names\
        order by localized_name\
        ;'
    )
}
initqueries = """
CREATE MATERIALIZED VIEW num_matches(num_matches)
as(
    select cast(count(1) as decimal) from match
);

CREATE MATERIALIZED VIEW player_hero_wins(match_id, hero_name, player_slot, won, gpm, xppm, damage, healing, tower_damage)
as(
    select players.match_id, hero_names.localized_name as hero_name, player_slot,
    ((radiant_win='True' AND player_slot<5) OR (radiant_win='False' AND player_slot>100)),
    gold_per_min, xp_per_min, hero_damage, hero_healing, tower_damage
    from players, match, hero_names
    where(
        match.match_id = players.match_id and
        players.hero_id = hero_names.hero_id
    )
);

CREATE MATERIALIZED VIEW hero_builds(hero_name, item0, item1, item2, item3, item4, item5,
build_count, win_rate, rn)
as(
    select localized_name, item0.item_name, item1.item_name, item2.item_name,
    item3.item_name, item4.item_name, item5.item_name, count, wr,
    row_number() over(partition by localized_name
    order by count DESC, wr DESC, item0.item_name, item1.item_name, item2.item_name, item3.item_name, item4.item_name, item5.item_name) rn
    from
    (
        select localized_name, item_0, item_1, item_2,item_3, item_4, item_5,
        count(1),
        sum(((radiant_win='True' AND player_slot<5) OR (radiant_win='False' AND player_slot>100))::int) as wr
        from hero_names, players, match
        where(
            hero_names.hero_id = players.hero_id AND
            match.match_id = players.match_id
        )
        group by localized_name, item_0, item_1, item_2, item_3, item_4, item_5
    ) dummy
    inner join item_ids as item0 on(dummy.item_0=item0.item_id)
    inner join item_ids as item1 on(dummy.item_1=item1.item_id)
    inner join item_ids as item2 on(dummy.item_2=item2.item_id)
    inner join item_ids as item3 on(dummy.item_3=item3.item_id)
    inner join item_ids as item4 on(dummy.item_4=item4.item_id)
    inner join item_ids as item5 on(dummy.item_5=item5.item_id)
)
;
"""
def views_init():
    print("Initialize Views")
    conn = pg.connect(host='localhost',dbname='project_db', user='postgres', port='5432', password='1234')
    try:
        cursor = conn.cursor()
        cursor.execute(initqueries)
        conn.commit()
    except (Exception, pg.Error) as error:
        print("Error while creating views from PostgreSQL", error)
    finally:
        if conn is not None:
            cursor.close()
            conn.close()

def query_main(query_num):
    if(query_num in qdict.keys()):
        header,query = qdict[query_num]
    else:
        print("[ ERROR ] - Query not in Dictionary")
        return (None,None)
    conn = pg.connect(host='localhost',dbname='project_db', user='postgres', port='5432', password='1234')
    data = None
    try:
        cursor = conn.cursor()
        cursor.execute(query)
        data = cursor.fetchall()
    except (Exception, pg.Error) as error:
        print("Error while fetching data from PostgreSQL", error)
    finally:
        if conn is not None:
            cursor.close()
            conn.close()
            return (header,data)


app = Flask(__name__)

@app.route('/')
def home():
    return render_template('index.html')

@app.route('/query',methods=['POST'])
def askquery():
    query = request.form['query']
    header,data = query_main(query)
    return render_template('index.html',header=header,data = data,typequery=query[0])

@app.route('/update')
def update():
    return render_template('index.html')

if __name__ == '__main__':
   app.run()
   views_init()
