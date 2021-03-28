from flask import Flask, render_template, request
import psycopg2 as pg
conn = pg.connect("dbname=project_db user=postgres password=password")

# General Queries
def query_q1():
    # Top k heroes most selected





    
app = Flask(__name__)

@app.route('/')
def home():
    return render_template('index.html')

@app.route('/query',methods=['POST'])
def askquery():
    query = request.form['query']
    return render_template('index.html')

@app.route('/update')
def update():
    return render_template('index.html')

if __name__ == '__main__':
   app.run()
   connect(
