# 📱 ViewController.swift – RoomBloom Funktionserklärung

## 🧠 `viewDidLoad()`
- Initialisiert die `ARView` und fügt sie dem UI hinzu
- Startet die horizontale Flächenerkennung (`startPlaneDetection`)
- Registriert Gesten:
  - Einfacher Tap → `handleTap`
  - Doppeltap → `handleDoubleTap`
  - Pinch (Zoom) → `handlePinch`
  - Ein-Finger-Wisch → `handleSingleFingerPan`
- Fügt „Clear“-Button zur Navigation hinzu

---

## 🔍 `startPlaneDetection()`
- Startet die AR-Session mit:
  - **Horizontaler Ebenenerkennung**
  - **Automatischer Umgebungs-Texturierung** (Reflexionen, Beleuchtung)

---

## 👆 `handleTap(recoginzer:)`
- Wird bei einfachem Tap aufgerufen
- Wenn auf ein Modell getippt → wird `selectedModel`
- Wenn auf Boden getippt:
  - Raycast erkennt horizontale Fläche
  - Modell wird je nach `modelName` geladen (`loadModel`)

---

## 📦 `loadModel(named:at:)`
- Lädt das 3D-Modell mit Name `modelName`
- Erstellt Kollisionsformen
- Ruft `placeObject(...)` auf, um Modell in Szene zu setzen

---

## 📍 `placeObject(object:at:)`
- Erstellt einen neuen `AnchorEntity` an der gegebenen Position
- Modell wird als Kind zum Anker hinzugefügt
- Anker zur Szene (`arView.scene`) hinzugefügt
- Speichert den Anker und das Modell in internen Listen

---

## 🔄 `handleRotation(_:)`
- Reagiert auf **Zwei-Finger-Rotation**
- Nur aktiv, wenn `isRotating == true`
- Rotiert das Modell um die **Y-Achse** mit Quaternion
- Setzt Geste zurück für inkrementelle Steuerung

---

## 🔍 `handlePinch(_:)`
- Skaliert das aktuelle Modell mit Pinch-Geste
- Multipliziert aktuelle Größe mit dem `gesture.scale`
- Setzt Geste auf `1.0` zurück, um neue Skalierung ab dort zu starten

---

## 👇 `handleDoubleTap(_:)`
- Schaltet zwischen:
  - `isRotating == true` (Rotieren)
  - `isRotating == false` (Bewegen)
- Gibt aktuellen Modus als Text in Konsole aus

---

## 🗑️ `clearScene()`
- Entfernt **alle Anker (Modelle)** aus der Szene
- Leert `placedAnchors` Array

---

## ☝️ `handleSingleFingerPan(_:)`
- Wenn `isRotating == true`:  
  → Modell rotiert um die Y-Achse je nach Wischrichtung
- Wenn `isRotating == false`:  
  → Führt Raycast durch  
  → Verschiebt Modell auf neue Position:
    - Entfernt aus altem Anker
    - Fügt in neuen Anker ein
    - Aktualisiert `placedAnchors`

---

# ✅ Gesamtziel
- **Modelle platzieren, skalieren, rotieren & verschieben**
- Mit intuitiven Gesten in AR interagieren
- Benutzerfreundlicher Moduswechsel durch Doppeltap