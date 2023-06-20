# Marvel Hero Gallery

Marvel Hero Gallery is an iOS app built using Swift that utilizes the Marvel API to fetch and display Marvel hero images in a horizontal scroll view. The app provides an immersive browsing experience where users can explore a vast collection of Marvel heroes. By leveraging the power of the Marvel API, the app dynamically loads hero images, ensuring a seamless and efficient user experience.

The app features a visually appealing interface where hero images are showcased in a horizontal scroll view. Users can effortlessly swipe through the collection and tap on a hero of interest to view a new screen dedicated to that hero. On the hero detail screen, users can admire a larger image of the hero and gain access to additional information, such as their biography, powers, and affiliations.

To ensure offline availability, the app incorporates local storage using RealmSwift. Hero images are stored locally, allowing users to access them even when there is no internet connection. This feature ensures a consistent and uninterrupted browsing experience, regardless of network availability.

## Features

- Fetches Marvel hero images from the Marvel API.
- Displays hero images in a visually appealing horizontal scroll view.
- Supports pull-to-refresh functionality to update the hero list.
- Utilizes local storage with RealmSwift for offline availability of hero images.
- Opens a new screen with a larger image and hero information when a hero is tapped.
- Dynamically loads hero images for smooth browsing experience.

## Installation

1. Clone the repository:

```bash
git clone https://github.com/andrey-pagin/MarvelHeroGallery.git
```

2. Navigate to the project directory:

```bash
cd marvel-hero-gallery
```

3. Install the required dependencies using Swift Package Manager:

```bash
swift package resolve
```

4. Open the Xcode workspace:

```bash
open MarvelHeroGallery.xcodeproj
```

5. Build and run the project in Xcode.

## Usage

1. Upon launching the app, the hero gallery will be displayed, showing the Marvel hero images in a horizontal scroll view.
2. Pull down on the hero gallery to trigger a refresh and fetch the latest hero images from the Marvel API. If there is no internet connection, the app will load hero images from local storage.
3. Tap on a hero image to open a new screen with a larger image of the hero and additional information.
4. Swipe left or right on the hero detail screen to navigate to the next or previous hero.

## Dependencies

The following dependencies are used in this project:

- [Alamofire](https://github.com/Alamofire/Alamofire): Used for network requests to the Marvel API.
- [Kingfisher](https://github.com/onevcat/Kingfisher): Used for image downloading and caching.
- [RealmSwift](https://github.com/realm/realm-cocoa): Used for local storage and offline availability of hero images.
- [SnapKit](https://github.com/SnapKit/SnapKit): Used for programmatic autolayout constraints.

All dependencies are managed using Swift Package Manager. The required versions of each dependency can be found in the `Package.swift` file.

## Contributing

Contributions to the Marvel Hero Gallery project are welcome! If you encounter any issues or have suggestions for improvements, please feel free to submit a pull request or open an issue on the GitHub repository.

## License

The Marvel Hero Gallery project is open-source and released under the [MIT License](LICENSE).

---

![demo](https://github.com/andrey-pagin/Effective_IOS_labs/blob/main/res/demo.gif?raw=true)
