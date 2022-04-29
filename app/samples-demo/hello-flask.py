from flask import Flask, flash, redirect, render_template, request, session, abort

app = Flask(__name__)

@app.route("/")
def index():
    return "Index!"

@app.route("/hello")
def hello():
    return "Hello World!"

#@app.route("/members")
#def members():
#    return "Members"
#
#@app.route("/members/<string:name>/")
#def getMember(name):
#    return name</string:name>

if __name__ == "__main__":
    # -- Use this when running inside container
    # default 5000
    #app.run(host='0.0.0.0') 
    # -- Use this when running at Host
    app.run(host='0.0.0.0', port=5333)
