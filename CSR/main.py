from flask import Blueprint, render_template
from flask_login import login_required, current_user

main_bp = Blueprint('main', __name__)

@main_bp.route('/')
def home():
    return render_template('home.html', title='Home')

@main_bp.route('/about')
def about():
    return render_template('about.html', title='About')

@main_bp.route('/dashboard')
@login_required
def dashboard():
    # Depending on your application's structure, you might pass additional data to the dashboard
    return render_template('dashboard.html', title='Dashboard', username=current_user.username)


#app = Flask(__name__)
#app.config['SQLALCHEMY_DATABASE_URI'] = 'sqlite:///charging_stations.db'
#app.secret_key = 'Uq-hv8ZJP7[F9+C'
#db = SQLAlchemy(app)

#login_manager = LoginManager()
#login_manager.init.app(app)

#def load_user(user_id):
 #   return User.query.get(int(user_id))




# Create the database
#with app.app_context():
 #   db.create_all()



#####################
######## API ########
#####################
    





SAMPLEJSON = """
[
   {
      "_id":"23",
      "location":"hejsavej 123",
      "charger_type":"type c",
      "reservation_status":"available"
   },
   {
      "_id":"24",
      "location":"hejsavej 456",
      "charger_type":"DisplayPort",
      "reservation_status":"reserved"
   }
]"""