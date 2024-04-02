from flask import jsonify


class ErrorMessage():
    def status_code_500(e):
        return jsonify({"error": "Internal server error", "message": str(e)}), 500
        