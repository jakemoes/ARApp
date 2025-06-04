//
//  ViewController.swift
//  RoomBloom
//
//  Created by Jakob Mösenbacher on 28.04.25.
//


import UIKit
import RealityKit
import ARKit

class ViewController: UIViewController {

    
    var modelName: String?
    
    var arView: ARView!
    var placedAnchors: [AnchorEntity] = []
    var selectedModel: ModelEntity?

    var isPanning = false
    var isRotating = false

    //Inatialisieren //Functionnen starten
    override func viewDidLoad() {
        super.viewDidLoad()
        
        arView = ARView(frame: .zero)
        arView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(arView)

        NSLayoutConstraint.activate([
            arView.topAnchor.constraint(equalTo: view.topAnchor),
            arView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            arView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            arView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])

        startPlaneDetection()

        arView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap(recoginzer:))))

        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(handlePinch(_:)))
        arView.addGestureRecognizer(pinchGesture)

        let doubleTapGesture = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap(_:)))
        doubleTapGesture.numberOfTapsRequired = 2
        arView.addGestureRecognizer(doubleTapGesture)

        let singleFingerPanGesture = UIPanGestureRecognizer(target: self, action: #selector(handleSingleFingerPan(_:)))
        singleFingerPanGesture.maximumNumberOfTouches = 1
        arView.addGestureRecognizer(singleFingerPanGesture)

        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Clear",
            style: .plain,
            target: self,
            action: #selector(clearScene)
        )
    }

    //Detects if there is an hoizontal space where the object can be placed
    func startPlaneDetection() {
        arView.automaticallyConfigureSession = true

        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = [.horizontal]
        configuration.environmentTexturing = .automatic

        arView.session.run(configuration)
    }

    //load Modell depending on what the user chose
    @objc func handleTap(recoginzer: UITapGestureRecognizer) {
        let tapLocation = recoginzer.location(in: arView)

        if let entity = arView.entity(at: tapLocation) as? ModelEntity {
            selectedModel = entity
            print("✅ Modell ausgewählt")
            return
        }

        let result = arView.raycast(from: tapLocation, allowing: .estimatedPlane, alignment: .horizontal)

        if let firstResult = result.first {
            let worldPos = simd_make_float3(firstResult.worldTransform.columns.3)
            
            switch modelName {
            case "redChair":
                loadModel(named: "chair_swan", at: worldPos)
            case "robot":
                loadModel(named: "robot_walk_idle", at: worldPos)
            case "pancakes":
                loadModel(named: "pancakes", at: worldPos)
            case "gramophone":
                loadModel(named: "gramophone", at: worldPos)
            case "guitar":
                loadModel(named: "fender_stratocaster", at: worldPos)
            case "coffeCup":
                loadModel(named: "cup_saucer_set", at: worldPos)
            default:
                print("Unbekanntes Tier")
            }
        }
    }

    
    
    //load Model
    func loadModel(named modelName: String, at location: SIMD3<Float>) {
        let modelEntity: ModelEntity
        do {
            let model = try Entity.loadModel(named: modelName)
            model.generateCollisionShapes(recursive: true)
            modelEntity = model
        } catch {
            print("❌ Fehler beim Laden des Modells: \(error)")
            return
        }

        placeObject(object: modelEntity, at: location)
    }

    
    //placint the opject
    func placeObject(object: ModelEntity, at location: SIMD3<Float>) {
        let anchor = AnchorEntity(world: location)
        anchor.addChild(object)
        arView.scene.addAnchor(anchor)
        placedAnchors.append(anchor)
        selectedModel = object
    }

    
    //rotation with 2 Fingers
    @objc func handleRotation(_ gesture: UIRotationGestureRecognizer) {
        guard let entity = selectedModel, isRotating else { return }
        print("🔄 Rotation erkannt – Modus: \(isRotating)")

        switch gesture.state {
        case .changed, .ended:
            let rotation = simd_quatf(angle: Float(gesture.rotation), axis: [0, 1, 0])
            var transform = entity.transform
            transform.rotation *= rotation
            entity.transform = transform
            gesture.rotation = 0
        default:
            break
        }
    }

    
    //change size
    @objc func handlePinch(_ gesture: UIPinchGestureRecognizer) {
        guard let entity = selectedModel else { return }

        switch gesture.state {
        case .changed, .ended:
            var transform = entity.transform
            let scaleFactor = Float(gesture.scale)
            transform.scale *= SIMD3<Float>(repeating: scaleFactor)
            entity.transform = transform
            gesture.scale = 1.0
        default:
            break
        }
    }

    
    //Mocint to Rotating
    @objc func handleDoubleTap(_ gesture: UITapGestureRecognizer) {
        isRotating.toggle()
        print(isRotating ? "✅ Rotation-Modus aktiviert" : "✅ Verschieben-Modus aktiviert")
    }

    
    //Delete all objects
    @objc func clearScene() {
        for anchor in placedAnchors {
            arView.scene.removeAnchor(anchor)
        }
        placedAnchors.removeAll()
    }

    
    //rotating or moving
    @objc func handleSingleFingerPan(_ gesture: UIPanGestureRecognizer) {
        guard let entity = selectedModel else { return }

        switch gesture.state {
        case .changed:
            if isRotating {
                let translation = gesture.translation(in: arView)
                let rotationAmount = Float(translation.x) * 0.005
                var transform = entity.transform
                transform.rotation *= simd_quatf(angle: rotationAmount, axis: [0, 1, 0])
                entity.transform = transform
                gesture.setTranslation(.zero, in: arView)
            } else {
                let location = gesture.location(in: arView)
                let results = arView.raycast(from: location, allowing: .estimatedPlane, alignment: .horizontal)
                if let firstResult = results.first {
                    let newPosition = simd_make_float3(firstResult.worldTransform.columns.3)
                    
                    // Neues AnchorEntity erzeugen
                    let newAnchor = AnchorEntity(world: newPosition)

                    // Altes AnchorEntity finden und entfernen
                    if let oldAnchor = placedAnchors.first(where: { $0.children.contains(entity) }) {
                        oldAnchor.removeChild(entity)
                        arView.scene.removeAnchor(oldAnchor)
                        placedAnchors.removeAll(where: { $0 == oldAnchor })
                    }

                    // Modell in neuen Anker verschieben
                    newAnchor.addChild(entity)
                    arView.scene.addAnchor(newAnchor)
                    placedAnchors.append(newAnchor)
                }
            }
        default:
            break
        }
    }
}
