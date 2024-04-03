from flask import jsonify, make_response

class ApiResponse():
    @staticmethod
    def _response(status, message=None, data=None, error=None, headers=None):
        """Private method to generate a JSON response with optional custom headers."""
        payload = {}
        if message:
            payload['message'] = message
        if data is not None:
            payload['data'] = data
        if error is not None:
            payload['error'] = error

        response = make_response(jsonify(payload), status)
        if headers:
            for key, value in headers.items():
                response.headers[key] = value
        return response

    @staticmethod
    def success(data=None, message="Success", status=200, headers=None):
        """General success response. (default 200 OK)"""
        return ApiResponse._response(status=status, message=message, data=data, headers=headers)
    
    @staticmethod
    def created(data=None, message="Resource successfully created", headers=None):
        """201 Created response for successfully created resources."""
        return ApiResponse._response(status=201, message=message, data=data, headers=headers)
        
    @staticmethod
    def error(message="An error occurred", status=400, error_details=None, headers=None):
        """Generic error response for providing flexibility with error codes."""
        return ApiResponse._response(status=status, error=message, data=error_details, headers=headers)

    @staticmethod
    def bad_request(message="Bad request", error_details=None, headers=None):
        """400 Bad Request response."""
        return ApiResponse.error(message=message, status=400, error_details=error_details, headers=headers)

    @staticmethod
    def forbidden(message="Forbidden", error_details=None, headers=None):
        """403 Forbidden response."""
        return ApiResponse.error(message=message, status=403, error_details=error_details, headers=headers)

    @staticmethod
    def not_found(message="Resource not found", error_details=None, headers=None):
        """404 Not Found response."""
        return ApiResponse.error(message=message, status=404, error_details=error_details, headers=headers)

    @staticmethod
    def internal_server_error(message="Internal server error", error_details=None, headers=None):
        """500 Internal Server Error."""
        return ApiResponse.error(message=message, status=500, error_details=error_details, headers=headers)