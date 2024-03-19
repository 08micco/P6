from flask import Flask
from flask_sqlalchemy import SQLAlchemy
from flask_login import LoginManager

db = SQLAlchemy
login_manager = LoginManager()

def create_app(config_class=Config):
    app=Flask(__name__)
    app.config.from_object(config_class)

    db.init_app(app)
    login_manager.init_app(app)

    from CSR.models import User, CorporateChargingStation, ChargingPoint, HouseholdChargingStation
    from CSR.models import User

    @login_manager.user_loader
    def load_user(user_id):
        return User.query.get(int(user_id))

    login_manager.login_view = 'auth.login'

    from CSR.auth import auth_bp
    from CSR.dashboard import dashboard_bp
    from CSR.main import main_bp
    app.register_blueprint(auth_bp)
    app.register_blueprint(dashboard_bp, url_prefix='/dashboard')
    app.register_blueprint(main_bp)

    with app.app_context():
        db.create_all()


    return app