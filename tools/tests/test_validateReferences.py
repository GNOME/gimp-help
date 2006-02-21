import unittest
import doctest, validate_references


def run_tests():
    suite = doctest.DocTestSuite(validate_references)
    runner = unittest.TextTestRunner()
    runner.run(suite)

if __name__ == "__main__":
    run_tests()
