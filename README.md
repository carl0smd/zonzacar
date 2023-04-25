# ZonzaCar

ZonzaCar is a car-sharing platform that allows users to share their cars with others, it was made to try to reduce the carbon footprint of the students at CIFP Zonzamas, Arrecife, Lanzarote, Spain.

## Table of Contents

- [Features](#features)
- [Installation](#installation)
- [Usage](#usage)
- [Contributing](#contributing)
- [License](#license)

## Features

- User authentication and registration
- Search for available cars by location and date range
- View users publications details and pricing
- Book and manage car reservations
- Integration with Google Maps for location-based search
- In-app messaging between car owners and passangers

## Installation

To install ZonzaCar, follow these steps:

1. Clone the repository: `git clone https://github.com/carl0smd/zonzacar.git`
2. Install dependencies: `flutter pub get`
3. Set up a Firebase project and enable Firebase Authentication and Cloud Firestore.
4. Create a `.env` file in the root directory.
5. Add the following environment variables to the `.env` file:

GOOGLE_MAPS_API_KEY=<your-google-maps-api-key>
FIREBASE_PROJECT_ID=<your-firebase-project-id>
FIREBASE_API_KEY=<your-firebase-api-key>
FIREBASE_AUTH_DOMAIN=<your-firebase-auth-domain>
FIREBASE_DATABASE_URL=<your-firebase-database-url>
FIREBASE_STORAGE_BUCKET=<your-firebase-storage-bucket>
FIREBASE_MESSAGING_SENDER_ID=<your-firebase-messaging-sender-id>
FIREBASE_APP_ID=<your-firebase-app-id>


6. Run the app on your emulator or physical device: `flutter run`

Note: You will need to obtain your own Google Maps API key and Firebase configuration values in order for the app to work correctly.

## Usage

To use ZonzaCar, follow these steps:

1. Run the app on your emulator or physical device: `flutter run`
2. Navigate to the login page and sign up for a new account or log in with an existing one.
3. Browse available cars by location and date range.
4. Select a publication to view more details and pricing information.
5. Book a reservation for the car.
6. Use the in-app messaging to communicate with the car owner and coordinate pick-up and drop-off.
7. Manage your reservations and car listings in the app.

## Contributing

We welcome contributions to ZonzaCar! If you find a bug or have an idea for a new feature, please create an issue or submit a pull request.

## License

This project is licensed under the MIT License. See the [LICENSE](https://github.com/carl0smd/zonzacar/blob/main/LICENSE) file for details.

