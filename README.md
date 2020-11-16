# RxMarvel

RxMarvel es un proyecto simple hecho en RxSwift y aplicando el patrón de arquitectura MVVM y test unitarios. Consiste en una app que se conecta a la API de Marvel para obtener sus personajes y mostrarlos en un listado - detalle.

## Installation

Requiere Cocoa Pods [Cocoa pods](https://guides.cocoapods.org/using/getting-started.html) para instalar RxSwift.

```bash
pod install
```

## Configuración
* Se necesita una [api key de Marvel](https://developer.marvel.com/)
* Hay que introducirla en el fichero de constantes *Constants.swift*

```swift

struct api_keys {
    static let `public` = "YOUR_PUBLIC_APIKEY"
    static let `private` = "YOUR_PRIVATE_APIKEY"
}
```

## Login
Para iniciar sesión en la pantalla login solamente hay que meter un email válido tipo email@valido.es y una contraseña válida de 6 caracteres tipo 123456