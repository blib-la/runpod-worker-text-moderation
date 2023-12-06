import runpod
from transformers import AutoModelForSequenceClassification, AutoTokenizer
import torch
from torch.nn.functional import softmax

# # Load the model and tokenizer from Hugging Face
# model = AutoModelForSequenceClassification.from_pretrained("KoalaAI/Text-Moderation")
# tokenizer = AutoTokenizer.from_pretrained("KoalaAI/Text-Moderation")

# Load the downloaded model
model = AutoModelForSequenceClassification.from_pretrained("/koalaai-text-moderation")
tokenizer = AutoTokenizer.from_pretrained("/koalaai-text-moderation")

# Mapping from ID to short label (from config.json)
id2label_short = {
    "0": "H",
    "1": "H2",
    "2": "HR",
    "3": "OK",
    "4": "S",
    "5": "S3",
    "6": "SH",
    "7": "V",
    "8": "V2",
}

# Mapping from short label to full label name (from README)
short_to_full_label = {
    "H": "hate",
    "H2": "hate/threatening",
    "HR": "harassment",
    "OK": "OK",
    "S": "sexual",
    "S3": "sexual/minors",
    "SH": "self-harm",
    "V": "violence",
    "V2": "violence/graphic",
}

# Create a list of full label names in the order of their IDs
labels = [
    short_to_full_label[id2label_short[str(i)]] for i in range(len(id2label_short))
]


def classify_text(text):
    """
    Classifies the given text using the text moderation model.

    Args:
    text (str): The text to classify.

    Returns:
    dict: A dictionary with labels as keys and their corresponding probabilities as values.
    """
    # Tokenize the input text
    inputs = tokenizer(text, return_tensors="pt")

    # Perform inference
    outputs = model(**inputs)

    # Apply softmax to convert logits into probabilities
    probabilities = softmax(outputs.logits, dim=1)

    # Pair probabilities with labels
    probabilities_with_labels = dict(zip(labels, probabilities[0].tolist()))

    return probabilities_with_labels


def handler(job):
    job_input = job["input"]

    result = classify_text(job_input.get("text"))

    print(result)

    return result


# Start the handler only if this script is run directly
if __name__ == "__main__":
    runpod.serverless.start({"handler": handler})
