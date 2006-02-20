import unittest
import doctest, validateReferences


def run_tests():
    suite = doctest.DocTestSuite(validateReferences)
    runner = unittest.TextTestRunner()
    runner.run(suite)

if __name__ == "__main__":
    run_tests()
