from flask import Flask, render_template, request
import psycopg2 as pg

# Queries Dictionary
qdict = {
    "q1":(["Hero Name"],"select min as hero_name from ( select min(localized_name), count(1) from players inner join hero_names using(hero_id) group by hero_id order by count desc limit 10 ) foo;"),
    "q3":(["Percentage of Radiant Wins"],   "select round(100*(numerator.count/num_matches.num_matches ),2)as radiant_wins from\
                                            num_matches,\
                                            (\
                                                select count(1) from match\
                                                where radiant_win = 'True'\
                                            ) numerator\
                                            ;")
}

def query_main(query_num):
    if(query_num in qdict.keys()):
        header,query = qdict[query_num]
    else:
        print("[ ERROR ] - Query not in Dictionary")
        return (None,None)
    conn = pg.connect(host='/var/run/postgresql',dbname='project_db', user='dhull', port='5432', password='1234')
    data = None
    try:
        cursor = conn.cursor()
        cursor.execute(query)
        data = cursor.fetchall()
    except (Exception, psycopg2.Error) as error:
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
    return render_template('index.html',header=header,data = data)

@app.route('/update')
def update():
    return render_template('index.html')

if __name__ == '__main__':
   app.run()
