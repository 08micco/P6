from flask import Flask
from flask_sqlalchemy import SQLAlchemy
from flask_login import LoginManager
from config import Config
from .main import main_bp

db = SQLAlchemy()
login_manager = LoginManager()

def create_app():
    app = Flask(__name__)
    app.config.from_object(Config)

    db.init_app(app)
    login_manager.init_app(app)

    from CSR.models import User
    @login_manager.user_loader
    def load_user(user_id):
        return User.query.get(int(user_id))
    login_manager.login_view = 'auth.login'

    from CSR.auth import auth_bp
    from CSR.main import main_bp
    app.register_blueprint(auth_bp)
    app.register_blueprint(main_bp, url_prefix='/')

    with app.app_context():
        db.create_all()
    return app
