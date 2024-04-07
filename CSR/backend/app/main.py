from flask import Blueprint, render_template
from flask_jwt_extended import jwt_required  

main_bp = Blueprint('main', __name__)

@main_bp.route('/')
def home():
    return render_template('home.html', title='Home')

@main_bp.route('/about')
def about():
    return render_template('about.html', title='About')

@main_bp.route('/dashboard')
@jwt_required()  
def dashboard():
    return render_template('dashboard.html', title='Dashboard')


#app = Flask(__name__)
#app.config['SQLALCHEMY_DATABASE_URI'] = 'sqlite:///charging_stations.db'
#app.config['Uq-hv8ZJP7[F9+C'] = 'Uq-hv8ZJP7[F9+C'
#app.secret_key = 'Uq-hv8ZJP7[F9+C'
#jwt = JWTManager

#login_manager = LoginManager()
#login_manager.init.app(app)

#def load_user(user_id):
 #   return User.query.get(int(user_id))




# Create the database
#with app.app_context():
 #   db.create_all()