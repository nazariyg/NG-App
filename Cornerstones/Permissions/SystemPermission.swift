// Copyright © 2021 Nazariy Gorpynyuk.
// All rights reserved.

import Foundation
import AVFoundation
import CoreLocation
import Photos
import MediaPlayer
import Contacts
import UserNotifications

public typealias StatusClosure = (_ status: SystemPermission.Status) -> Void

public enum SystemPermission {

    case camera
    case microphone
    case location
    case photosVideos
    case media
    case contacts
    case notifications

    public enum Status {
        case undetermined
        case denied
        case grantedWhenInUse  // location only
        case granted
    }

    public enum PermissionContinuity {
        case whenInUse
        case always
    }

    public static let defaultNotificationsOptions: UNAuthorizationOptions = [.alert, .sound, .badge]

    private static let permissionManager = SystemPermissionManager()

    /// The `completion` closure is always run on the main queue.
    public func status(completion: @escaping StatusClosure) {
        DispatchQueue.main.async {
            Self.permissionManager.status(forPermission: self, completion: completion)
        }
    }

    /// The `completion` closure is always run on the main queue.
    public func request(
        completion: @escaping StatusClosure, permissionContinuity: PermissionContinuity = .whenInUse,
        notificationsOptions: UNAuthorizationOptions = defaultNotificationsOptions) {

        DispatchQueue.main.async {
            Self.permissionManager.request(
                permission: self, completion: completion, permissionContinuity: permissionContinuity, notificationsOptions: notificationsOptions)
        }
    }

    /// The `completion` closure is always run on the main queue.
    public func requestIfNeeded(
        completion: @escaping StatusClosure, permissionContinuity: PermissionContinuity = .whenInUse,
        notificationsOptions: UNAuthorizationOptions = defaultNotificationsOptions) {

        DispatchQueue.main.async {
            Self.permissionManager.requestIfNeeded(
                permission: self, completion: completion, permissionContinuity: permissionContinuity, notificationsOptions: notificationsOptions)
        }
    }

}

private final class SystemPermissionManager: NSObject {

    private struct LocationPermissionRequest {
        let continuity: SystemPermission.PermissionContinuity
        let requestCompletion: StatusClosure
        let locationManager = CLLocationManager()
    }

    private struct InfoDictionaryUsageDescriptionKey {
        static let camera = "NSCameraUsageDescription"
        static let microphone = "NSMicrophoneUsageDescription"
        static let locationWhenInUse = "NSLocationWhenInUseUsageDescription"
        static let locationAlways = "NSLocationAlwaysAndWhenInUseUsageDescription"
        static let photosVideos = "NSPhotoLibraryUsageDescription"
        static let media = "NSAppleMusicUsageDescription"
        static let contacts = "NSContactsUsageDescription"
    }

    // For thread-safety.
    private var activeLocationPermissionRequests: [LocationPermissionRequest] = []
    private let locationPermissionLock = VoidObject()

    fileprivate override init() {}

    fileprivate func status(forPermission permissionType: SystemPermission, completion: @escaping StatusClosure) {
        switch permissionType {
        case .camera:
            let status = statusForCamera()
            deliverStatus(status: status, completion: completion)
        case .microphone:
            let status = statusForMicrophone()
            deliverStatus(status: status, completion: completion)
        case .location:
            let status = statusForLocation()
            deliverStatus(status: status, completion: completion)
        case .photosVideos:
            let status = statusForPhotosVideos()
            deliverStatus(status: status, completion: completion)
        case .media:
            let status = statusForMedia()
            deliverStatus(status: status, completion: completion)
        case .contacts:
            let status = statusForContacts()
            deliverStatus(status: status, completion: completion)
        case .notifications:
            statusForNotifications(completion: completion)
        }
    }

    fileprivate func request(
        permission permissionType: SystemPermission, completion: @escaping StatusClosure, permissionContinuity: SystemPermission.PermissionContinuity,
        notificationsOptions: UNAuthorizationOptions) {

        switch permissionType {
        case .camera:
            requestCamera(completion: completion)
        case .microphone:
            requestMicrophone(completion: completion)
        case .location:
            requestLocation(completion: completion, permissionContinuity: permissionContinuity)
        case .photosVideos:
            requestPhotosVideos(completion: completion)
        case .media:
            requestMedia(completion: completion)
        case .contacts:
            requestContacts(completion: completion)
        case .notifications:
            requestNotifications(completion: completion, notificationsOptions: notificationsOptions)
        }
    }

    fileprivate func requestIfNeeded(
        permission permissionType: SystemPermission, completion: @escaping StatusClosure, permissionContinuity: SystemPermission.PermissionContinuity,
        notificationsOptions: UNAuthorizationOptions) {

        switch permissionType {
        case .camera:
            let currentStatus = statusForCamera()
            if currentStatus == .undetermined {
                requestCamera(completion: completion)
            }
        case .microphone:
            let currentStatus = statusForMicrophone()
            if currentStatus == .undetermined {
                requestMicrophone(completion: completion)
            }
        case .location:
            let currentStatus = statusForLocation()
            if currentStatus == .undetermined {
                requestLocation(completion: completion, permissionContinuity: permissionContinuity)
            }
        case .photosVideos:
            let currentStatus = statusForPhotosVideos()
            if currentStatus == .undetermined {
                requestPhotosVideos(completion: completion)
            }
        case .media:
            let currentStatus = statusForMedia()
            if currentStatus == .undetermined {
                requestMedia(completion: completion)
            }
        case .contacts:
            let currentStatus = statusForContacts()
            if currentStatus == .undetermined {
                requestContacts(completion: completion)
            }
        case .notifications:
            statusForNotifications(completion: { [weak self] currentStatus in
                guard let self = self else { return }
                if currentStatus == .undetermined {
                    self.requestNotifications(completion: completion, notificationsOptions: notificationsOptions)
                }
            })
        }
    }

    // MARK: - Private

    private func deliverStatus(status: SystemPermission.Status, completion: @escaping StatusClosure) {
        DispatchQueue.main.async {
            completion(status)
        }
    }

    // MARK: - Status requesting

    private func statusForCamera() -> SystemPermission.Status {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        return status.permissionStatus
    }

    private func statusForMicrophone() -> SystemPermission.Status {
        let status = AVCaptureDevice.authorizationStatus(for: .audio)
        return status.permissionStatus
    }

    private func statusForLocation() -> SystemPermission.Status {
        let status = CLLocationManager.authorizationStatus()
        return status.permissionStatus
    }

    private func statusForPhotosVideos() -> SystemPermission.Status {
        let status = PHPhotoLibrary.authorizationStatus()
        return status.permissionStatus
    }

    private func statusForMedia() -> SystemPermission.Status {
        let status = MPMediaLibrary.authorizationStatus()
        return status.permissionStatus
    }

    private func statusForContacts() -> SystemPermission.Status {
        let status = CNContactStore.authorizationStatus(for: .contacts)
        return status.permissionStatus
    }

    private func statusForNotifications(completion: @escaping StatusClosure) {
        let center = UNUserNotificationCenter.current()
        center.getNotificationSettings { [weak self] settings in
            guard let self = self else { return }
            let status = settings.authorizationStatus.permissionStatus
            self.deliverStatus(status: status, completion: completion)
        }
    }

    // MARK: - Permission requesting

    private func requestCamera(completion: @escaping StatusClosure) {
        if validateCameraPermissionRequest() {
            AVCaptureDevice.requestAccess(for: .video, completionHandler: { [weak self] granted in
                guard let self = self else { return }
                let status = granted.permissionStatus
                self.deliverStatus(status: status, completion: completion)
            })
        } else {
            deliverStatus(status: .undetermined, completion: completion)
        }
    }

    private func requestMicrophone(completion: @escaping StatusClosure) {
        if validateMicrophonePermissionRequest() {
            AVCaptureDevice.requestAccess(for: .audio, completionHandler: { [weak self] granted in
                guard let self = self else { return }
                let status = granted.permissionStatus
                self.deliverStatus(status: status, completion: completion)
            })
        } else {
            deliverStatus(status: .undetermined, completion: completion)
        }
    }

    private func makeLocationPermissionRequest(request: LocationPermissionRequest) {
        synchronized(locationPermissionLock) {
            activeLocationPermissionRequests.append(request)
            request.locationManager.delegate = self
            switch request.continuity {
            case .whenInUse:
                request.locationManager.requestWhenInUseAuthorization()
            case .always:
                request.locationManager.requestAlwaysAuthorization()
            }
        }
    }

    private func requestLocation(completion: @escaping StatusClosure, permissionContinuity: SystemPermission.PermissionContinuity) {
        let request = LocationPermissionRequest(continuity: permissionContinuity, requestCompletion: { [weak self] status in
            self?.deliverStatus(status: status, completion: completion)
        })
        if validateLocationPermissionRequest(request: request) {
            makeLocationPermissionRequest(request: request)
        } else {
            deliverStatus(status: .undetermined, completion: completion)
        }
    }

    private func requestPhotosVideos(completion: @escaping StatusClosure) {
        if validatePhotosVideosPermissionRequest() {
            PHPhotoLibrary.requestAuthorization { [weak self] status in
                guard let self = self else { return }
                let permissionStatus = status.permissionStatus
                self.deliverStatus(status: permissionStatus, completion: completion)
            }
        } else {
            deliverStatus(status: .undetermined, completion: completion)
        }
    }

    private func requestMedia(completion: @escaping StatusClosure) {
        if validateMediaPermissionRequest() {
            MPMediaLibrary.requestAuthorization { [weak self] status in
                guard let self = self else { return }
                let permissionStatus = status.permissionStatus
                self.deliverStatus(status: permissionStatus, completion: completion)
            }
        } else {
            deliverStatus(status: .undetermined, completion: completion)
        }
    }

    private func requestContacts(completion: @escaping StatusClosure) {
        if validateContactsPermissionRequest() {
            CNContactStore().requestAccess(for: .contacts) { [weak self] granted, _ in
                guard let self = self else { return }
                let status = granted.permissionStatus
                self.deliverStatus(status: status, completion: completion)
            }
        } else {
            deliverStatus(status: .undetermined, completion: completion)
        }
    }

    private func requestNotifications(completion: @escaping StatusClosure, notificationsOptions: UNAuthorizationOptions) {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: notificationsOptions) { [weak self] granted, _ in
            guard let self = self else { return }
            let status = granted.permissionStatus
            self.deliverStatus(status: status, completion: completion)
        }
    }

    // MARK: - Validation

    private func validateCameraPermissionRequest() -> Bool {
        var isValid = false
        let info = Bundle.main.infoDictionary
        if let usageDescription = info?[InfoDictionaryUsageDescriptionKey.camera] as? String {
            isValid = usageDescription._isNotEmpty
        }
        assert(isValid, "Usage description is missing from Info.plist for this camera permission request")
        return isValid
    }

    private func validateMicrophonePermissionRequest() -> Bool {
        var isValid = false
        let info = Bundle.main.infoDictionary
        if let usageDescription = info?[InfoDictionaryUsageDescriptionKey.microphone] as? String {
            isValid = usageDescription._isNotEmpty
        }
        assert(isValid, "Usage description is missing from Info.plist for this microphone permission request")
        return isValid
    }

    private func validateLocationPermissionRequest(request: LocationPermissionRequest) -> Bool {
        var isValid = false
        let info = Bundle.main.infoDictionary
        switch request.continuity {
        case .whenInUse:
            if let usageDescription = info?[InfoDictionaryUsageDescriptionKey.locationWhenInUse] as? String {
                isValid = usageDescription._isNotEmpty
            }
        case .always:
            if let usageDescription = info?[InfoDictionaryUsageDescriptionKey.locationAlways] as? String {
                isValid = usageDescription._isNotEmpty
            }
        }
        assert(isValid, "Usage description is missing from Info.plist for this type of location permission request")
        return isValid
    }

    private func validatePhotosVideosPermissionRequest() -> Bool {
        var isValid = false
        let info = Bundle.main.infoDictionary
        if let usageDescription = info?[InfoDictionaryUsageDescriptionKey.photosVideos] as? String {
            isValid = usageDescription._isNotEmpty
        }
        assert(isValid, "Usage description is missing from Info.plist for this photos/videos permission request")
        return isValid
    }

    private func validateMediaPermissionRequest() -> Bool {
        var isValid = false
        let info = Bundle.main.infoDictionary
        if let usageDescription = info?[InfoDictionaryUsageDescriptionKey.media] as? String {
            isValid = usageDescription._isNotEmpty
        }
        assert(isValid, "Usage description is missing from Info.plist for this media permission request")
        return isValid
    }

    private func validateContactsPermissionRequest() -> Bool {
        var isValid = false
        let info = Bundle.main.infoDictionary
        if let usageDescription = info?[InfoDictionaryUsageDescriptionKey.contacts] as? String {
            isValid = usageDescription._isNotEmpty
        }
        assert(isValid, "Usage description is missing from Info.plist for this contacts permission request")
        return isValid
    }

}

extension SystemPermissionManager: CLLocationManagerDelegate {

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        // `.notDetermined` is what's likely to get received first when requesting a permission.
        guard status != .notDetermined else { return }

        var request: LocationPermissionRequest?
        synchronized(locationPermissionLock) {
            let requestIndex = activeLocationPermissionRequests.firstIndex(where: { element -> Bool in
                return element.locationManager === manager
            })
            if let requestIndex = requestIndex {
                request = activeLocationPermissionRequests[requestIndex]
                activeLocationPermissionRequests.remove(at: requestIndex)
            }
        }
        if let request = request {
            let permissionStatus = status.permissionStatus
            deliverStatus(status: permissionStatus, completion: request.requestCompletion)
        }
    }

}

private protocol PermissionStatusConvertible {
    var permissionStatus: SystemPermission.Status { get }
}

extension AVAuthorizationStatus: PermissionStatusConvertible {

    var permissionStatus: SystemPermission.Status {
        switch self {
        case .notDetermined:
            return .undetermined
        case .denied, .restricted:
            return .denied
        case .authorized:
            return .granted
        @unknown default:
            fatalError()
        }
    }

}

extension CLAuthorizationStatus: PermissionStatusConvertible {

    var permissionStatus: SystemPermission.Status {
        switch self {
        case .notDetermined:
            return .undetermined
        case .denied, .restricted:
            return .denied
        case .authorizedWhenInUse:
            return .grantedWhenInUse
        case .authorizedAlways:
            return .granted
        @unknown default:
            fatalError()
        }
    }

}

extension PHAuthorizationStatus: PermissionStatusConvertible {

    var permissionStatus: SystemPermission.Status {
        switch self {
        case .notDetermined:
            return .undetermined
        case .denied, .restricted:
            return .denied
        case .authorized, .limited:
            return .granted
        @unknown default:
            fatalError()
        }
    }

}

extension MPMediaLibraryAuthorizationStatus: PermissionStatusConvertible {

    var permissionStatus: SystemPermission.Status {
        switch self {
        case .notDetermined:
            return .undetermined
        case .denied, .restricted:
            return .denied
        case .authorized:
            return .granted
        @unknown default:
            fatalError()
        }
    }

}

extension CNAuthorizationStatus: PermissionStatusConvertible {

    var permissionStatus: SystemPermission.Status {
        switch self {
        case .notDetermined:
            return .undetermined
        case .denied, .restricted:
            return .denied
        case .authorized:
            return .granted
        @unknown default:
            fatalError()
        }
    }

}

extension UNAuthorizationStatus: PermissionStatusConvertible {

    var permissionStatus: SystemPermission.Status {
        switch self {
        case .notDetermined:
            return .undetermined
        case .denied:
            return .denied
        case .authorized, .provisional, .ephemeral:
            return .granted
        @unknown default:
            fatalError()
        }
    }

}

extension Bool: PermissionStatusConvertible {

    var permissionStatus: SystemPermission.Status {
        switch self {
        case false:
            return .denied
        case true:
            return .granted
        }
    }

}
