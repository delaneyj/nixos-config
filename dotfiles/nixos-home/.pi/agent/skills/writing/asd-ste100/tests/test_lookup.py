#!/usr/bin/env python3

import json
import subprocess
import sys
import unittest
from pathlib import Path


class LookupTest(unittest.TestCase):
    def run_lookup(self, *args: str) -> subprocess.CompletedProcess[str]:
        script = Path(__file__).parents[1] / "scripts" / "lookup.py"
        return subprocess.run(
            [sys.executable, str(script), *args],
            check=False,
            capture_output=True,
            text=True,
        )

    def test_finds_an_exact_rule_id(self) -> None:
        completed = self.run_lookup("rule", "R1.1", "--field", "id", "--exact")

        self.assertEqual(0, completed.returncode, completed.stderr)
        result = json.loads(completed.stdout)
        self.assertEqual(1, result["match_count"])
        self.assertEqual("R1.1", result["results"][0]["id_"])

    def test_exact_word_lookup_preserves_parts_of_speech_and_statuses(self) -> None:
        completed = self.run_lookup("word", "test", "--source", "core", "--field", "name", "--exact")

        self.assertEqual(0, completed.returncode, completed.stderr)
        result = json.loads(completed.stdout)
        self.assertEqual(
            [("TEST", "approved", "n"), ("test", "rejected", "v")],
            [(item["name"], item["status"], item["type_"]) for item in result["results"]],
        )

    def test_finds_a_technical_term(self) -> None:
        completed = self.run_lookup(
            "word", "access ladder", "--source", "technical", "--field", "name", "--exact"
        )

        self.assertEqual(0, completed.returncode, completed.stderr)
        result = json.loads(completed.stdout)
        self.assertEqual(1, result["match_count"])
        self.assertEqual("TN3", result["results"][0]["category"])

    def test_reports_truncated_results(self) -> None:
        completed = self.run_lookup("word", ".", "--source", "core", "--field", "name", "--limit", "1")

        self.assertEqual(0, completed.returncode, completed.stderr)
        result = json.loads(completed.stdout)
        self.assertGreater(result["match_count"], result["returned_count"])
        self.assertEqual(1, result["returned_count"])
        self.assertTrue(result["truncated"])

    def test_rejects_an_invalid_regular_expression(self) -> None:
        completed = self.run_lookup("rule", "[")

        self.assertEqual(2, completed.returncode)
        self.assertIn("invalid regular expression", completed.stderr)


if __name__ == "__main__":
    unittest.main()
