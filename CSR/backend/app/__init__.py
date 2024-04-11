from flask import Flask
from flask_cors import CORS
from config import Config
from .extensions import db, login_manager

def create_app():
    app = Flask(__name__)
    app.config.from_object(Config)
    CORS(app, resources={r"/*": {"origins": "*"}})


    db.init_app(app)
    login_manager.init_app(app)

    

    @login_manager.user_loader
    def load_user(user_id):
        return User.query.get(int(user_id))
    login_manager.login_view = 'auth.login'

    from .models import User
    from .routes import configure_routes
    from .auth import auth_bp
    from .main import main_bp
    app.register_blueprint(auth_bp)
    app.register_blueprint(main_bp, url_prefix='/')
    configure_routes(app)

    with app.app_context():
        db.create_all()

    return app