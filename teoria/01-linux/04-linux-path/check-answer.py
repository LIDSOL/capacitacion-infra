# Script to extract check quiz answers from the linux-path repository.
# https://github.com/daquino94/linux-path

import os
import json
import sys
import argparse

def parse_arguments():
    parser = argparse.ArgumentParser(description='Check answers for Linux Path quizzes.')
    parser.add_argument('--answer-file', type=str, default="answer.json",
                      help='Path to the answer.json file to check (default: answer.json)')
    return parser.parse_args()
args = parse_arguments()

BASE_DIR = os.path.join(os.getcwd(),"linux-path", "dictionaries", "en", "chapters")

if not os.path.exists(BASE_DIR):
    print(f"Base directory {BASE_DIR} does not exist. Please check the repository structure.")
    sys.exit(1)

if not os.path.exists(args.answer_file):
    print(f"Answer file {args.answer_file} does not exist. Please provide a valid answer file.")
    sys.exit(1)

quiz_data = {}

# Loop through each chapter directory
for chapter in os.listdir(BASE_DIR):
    chapter_data = {}
    chapter_path = os.path.join(BASE_DIR, chapter)
    for section in os.listdir(chapter_path):
        with open(os.path.join(chapter_path, section), 'r', encoding='utf-8') as file:
            data = json.load(file)
            quizQuestion = data.get('quizQuestion', '')
            quizAnswer = data.get('quizAnswer', '')
            if quizQuestion and quizAnswer:
                chapter_data[section[:-5]] = {
                    'quizQuestion': quizQuestion,
                    'quizAnswer': quizAnswer
                }
    quiz_data[chapter] = chapter_data

# Read the answer file
with open(args.answer_file, 'r', encoding='utf-8') as answer_file:
    answers = json.load(answer_file)

# Check if the answers match the quiz data
correct = 0
incorrect = 0

def normalize_answer(answer):
    """Normalize an answer for comparison: lowercase and strip whitespace around commas."""
    # Convert to lowercase
    normalized = answer.lower()
    # Handle comma-separated lists by removing spaces around commas
    if ',' in normalized:
        parts = [part.strip() for part in normalized.split(',')]
        parts.sort()
        normalized = ','.join(parts)
    return normalized

for chapter in quiz_data.keys():
    for section in quiz_data[chapter].keys():
        # Normalize answers for comparison
        correct_answer = normalize_answer(quiz_data[chapter][section]['quizAnswer'])
        user_answer = normalize_answer(answers[chapter][section]['quizAnswer'])

        if correct_answer == user_answer:
            correct += 1
        else:
            incorrect += 1
            # Print details about incorrect answers to help users
            print(f"Incorrect answer for {chapter}/{section}:")
            print(f"Question: {quiz_data[chapter][section]['quizQuestion']}")
            print(f"Your answer: {answers[chapter][section]['quizAnswer']}")
            print("----")

# Print the summary of results
print(f"\nTotal correct answers: {correct}")
print(f"Total incorrect answers: {incorrect}")

# Exit with a non-zero code if there are incorrect answers
if incorrect > 0:
    print(f"Some answers in {args.answer_file} are incorrect. Please review and fix them.")
    sys.exit(1)
else:
    print(f"All answers in {args.answer_file} are correct! Great job!")
    sys.exit(0)
