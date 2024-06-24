from flask_testing import TestCase
from CSR.backend.app import create_app, db
from CSR.backend.app.models import ChargingStation

class BaseTestCase(TestCase):
    def create_app(self):
        app = create_app()
        app.config['TESTING'] = True
        app.config['SQLALCHEMY_DATABASE_URI'] = 'sqlite:///:memory:'
        return app

    def setUp(self):
        db.create_all()

    def tearDown(self):
        db.session.remove()
        db.drop_all()


class TestGetChargingStation(BaseTestCase):
    def test_get_charging_station(self):
        station = ChargingStation(
            id=1,
            owner_id=1,
            title='Station1',
            subtitle='Quick Charge',
            description='High power charging station',
            company_name='CSR Energy',
            charging_station_type='Corporate',
            address='1234 Electric Ave',
            latitude='34.0522 N',
            longitude='118.2437 W',
            charging_points=4,
            charger_type='Type2',
            available=True,
            phone_number='123-456-7890'
        )
        db.session.add(station)
        db.session.commit()

        response = self.client.get('/chargingStation/get/1')
        self.assertEqual(response.status_code, 200)
        self.assertIn('Station1', response.json['data'][0]['title'])
        self.assertEqual('Quick Charge', response.json['data'][0]['subtitle'])

    def test_get_charging_station_not_found(self):
        response = self.client.get('/chargingStation/get/99')
        self.assertEqual(response.status_code, 404)
        self.assertIn('Charging station not found', response.json['error'])



class TestNewReservation(BaseTestCase):
    def setUp(self):
        super().setUp()
        station = ChargingStation(
            id=1, title='Station1', address='Address1', charging_station_type='Corporate',
            latitude='34.0522 N', longitude='118.2437 W', charging_points=2,
            charger_type='Type2', available=True)
        db.session.add(station)
        db.session.commit()

    def test_create_reservation(self):
        data = {
            "user_id": "1",
            "reservation_time": 30,
            "reservation_start_time": "2024-06-22T10:00:00",
            "reservation_end_time": "2024-06-22T10:30:00"
        }
        response = self.client.post('/reservation/new/1', json=data)
        self.assertEqual(response.status_code, 201)
        self.assertIn('Sat, 22 Jun 2024 10:00:00', response.json['data']['reservation_start_time'].replace(' GMT', ''))


    def test_create_reservation_missing_field(self):
        data = {
            "user_id": "1",
            "reservation_start_time": "2024-06-22T10:00:00"
        }
        response = self.client.post('/reservation/new/1', json=data)
        self.assertEqual(response.status_code, 400)
        self.assertIn('Missing field', response.json['error'])

    def test_create_reservation_bad_data(self):
        data = {
            "user_id": "1",
            "reservation_time": 30,
            "reservation_start_time": "invalid-date",
            "reservation_end_time": "invalid-date"
        }
        response = self.client.post('/reservation/new/1', json=data)
        self.assertEqual(response.status_code, 400)
        self.assertIn('Invalid date format', response.json['error'])
