import unittest
from unittest.mock import patch
import pytest

from app.services.speedCalculator import SpeedCalculator
from app.core.exceptions import ValidationException

class TestSpeedCalculator(unittest.TestCase):
    
    def test_calculate_normal_case(self):

        initial_speeds_and_final_values = [ (60, 75), (75, 90), (80, 95)]
        for initial_speed, final_value in initial_speeds_and_final_values:
            inclines = [0, 30, 0, -45, 0]
            result = SpeedCalculator.calculate(initial_speed, inclines)
            self.assertEqual(result, final_value)
    
    def test_speed_become_zero(self):
        initial_speed = 90
        inclines = [0, 30, 30, 30,  0, -45, 0]
        result = SpeedCalculator.calculate(initial_speed, inclines)
        self.assertEqual(result, 0)
            
    
    def test_zero_initial_speed(self):
        initial_speed = 0
        inclines = [0, 30, 0]
        with self.assertRaises(ValidationException):
            SpeedCalculator.calculate(initial_speed, inclines)
    
    def test_invalid_incline_too_high(self):
        initial_speed = 60
        inclines = [0, 91, 0]
        with self.assertRaises(ValidationException):
            SpeedCalculator.calculate(initial_speed, inclines)
    
    def test_invalid_incline_too_low(self):
        initial_speed = 60
        inclines = [0, -91, 0]
        with self.assertRaises(ValidationException):
            SpeedCalculator.calculate(initial_speed, inclines)
    
    @patch('app.services.speedCalculator.logger')
    def test_logging_for_invalid_initial_speed(self, mock_logger):
        initial_speed = -10
        inclines = [0, 30, 0]
        with self.assertRaises(ValidationException):
            SpeedCalculator.calculate(initial_speed, inclines)
        mock_logger.error.assert_called_once()

if __name__ == '__main__':
    unittest.main()