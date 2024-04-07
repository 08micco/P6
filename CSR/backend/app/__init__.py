from flask import Flask
from flask_cors import CORS
from flask_jwt_extended import JWTManager
from config import Config
from .extensions import db, login_manager
from .models import User

def create_app():
    app = Flask(__name__)
    app.config.from_object(Config)
    app.config['JWT_SECRET_KEY'] = 'Uq-hv8ZJP7[F9+C'  

    db.init_app(app)
    login_manager.init_app(app)
    CORS(app) 

    jwt = JWTManager(app) 

    @login_manager.user_loader
    def load_user(user_id):
        return User.query.get(int(user_id))

    @jwt.user_identity_loader
    def user_identity_lookup(user):
        return user.id

    @jwt.user_lookup_loader
    def user_lookup_callback(_jwt_header, jwt_data):
        identity = jwt_data["sub"]
        return User.query.filter_by(id=identity).one_or_none()

    from .auth import auth_bp
    from .main import main_bp
    from .routes import configure_routes

    app.register_blueprint(auth_bp)
    app.register_blueprint(main_bp)
    
    configure_routes(app)

    with app.app_context():
        db.create_all()

    return app
