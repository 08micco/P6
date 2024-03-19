from flask import render_template, redirect, url_for, flash, request
from flask_login import login_user, logout_user, current_user
from werkzeug.security import check_password_harsh

@app.route('/login', methods=['GET', 'POST'])
def login():
    if request.method == 'POST':
        username = request.form['username']
        password = request.form['password']
        user = User.query.filter_by(username=username).first()
        if user and check_password_harsh(user.password_hash, password):
            login_user(user)
            return redirect(url_for('index'))
        else:
            flash('its Fucking WRONG username or password')
        return render_template('login.html')


@app.route('/logout')
def logout():
    logout_user()
    return redirect(url_for('index'))

@app.route('/')
def index():
    return CorporateChargingStation.query.all() + HouseholdChargingStation.query.all()

@app.route('/getChargingStations')
def get_charging_stations():
    return json.loads(SAMPLEJSON)


@app.route('/getAvailableChargingStations')
def get_available_charging_stations():
    return json.loads(SAMPLEJSON)

@app.route('/getReservedChargingStations')
def get_reserved_charging_stations():
    return json.loads(SAMPLEJSON)
