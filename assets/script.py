import cv2
import os
import numpy as np

class FingerprintMatcher:
    def _init_(self):
        self.minutiae_detector = cv2.AKAZE_create()
        self.distance_threshold = 0.1  # Set a threshold for considering a match (adjust based on your data)

    def extract_minutiae(self, image):
        gray = cv2.cvtColor(image, cv2.COLOR_BGR2GRAY)
        _, binary_image = cv2.threshold(gray, 128, 255, cv2.THRESH_BINARY)

        keypoints, _ = self.minutiae_detector.detectAndCompute(binary_image, None)
        minutiae = np.array([keypoint.pt for keypoint in keypoints], dtype=np.float32)

        return minutiae

    def train(self, target_folder):
        target_minutiae = []
        target_filenames = []

        for label, filename in enumerate(os.listdir(target_folder)):
            if filename.lower().endswith((".png", ".jpg", ".bmp")):
                image_path = os.path.join(target_folder, filename)
                image = cv2.imread(image_path)
                minutiae = self.extract_minutiae(image)

                target_minutiae.append(minutiae)
                target_filenames.append(filename)

        if not target_minutiae:
            raise ValueError("No fingerprints found in the target folder.")

        self.target_minutiae = target_minutiae
        self.target_filenames = target_filenames

    def match_fingerprint(self, query_image):
        query_minutiae = self.extract_minutiae(query_image)

        best_match_index = -1
        best_match_distance = float('inf')

        for i, target_minutia in enumerate(self.target_minutiae):
            # Calculate shape similarity using cv2.matchShapes
            distance = cv2.matchShapes(query_minutiae, target_minutia, cv2.CONTOURS_MATCH_I1, 0.0)

            if distance < best_match_distance:
                best_match_distance = distance
                best_match_index = i

        if best_match_distance < self.distance_threshold:
            if best_match_distance == 0:
                best_match_filename = self.target_filenames[best_match_index]
                return f"Matching fingerprint with label {best_match_index}, File Name: {best_match_filename}"
            else:
                return "No matching fingerprint"
        else:
            return "No matching fingerprint"

if _name_ == "_main_":
    matcher = FingerprintMatcher()

    query_folder = "C:/Users/yusuf/5678"
    target_folder = "C:/Users/yusuf/1234"  # Update to your larger folder

    try:
        matcher.train(target_folder)

        for query_filename in os.listdir(query_folder):
            if query_filename.lower().endswith((".png", ".jpg", ".bmp")):
                query_image_path = os.path.join(query_folder, query_filename)
                query_image = cv2.imread(query_image_path)

                result = matcher.match_fingerprint(query_image)
                print(f"Best match for {query_filename}: {result}")
    except ValueError as e:
        print(e)