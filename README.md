# StudyAI 📚

![StudyAI CI](https://github.com/mikhailfernandez333-dot/StudyAI/actions/workflows/ci.yml/badge.svg)

**StudyAI** es una aplicación móvil desarrollada con Flutter y Dart, orientada a apoyar el aprendizaje y facilitar las actividades de estudio mediante herramientas digitales.

## 🎯 Objetivo del proyecto

Desarrollar una aplicación móvil que proporcione herramientas de apoyo académico, ofreciendo una experiencia sencilla e intuitiva para los estudiantes.

## 🚀 Tecnologías utilizadas

- **Flutter:** framework para el desarrollo de aplicaciones multiplataforma.
- **Dart:** lenguaje de programación utilizado en el desarrollo.
- **Firebase Authentication:** gestión de autenticación de usuarios.
- **Cloud Firestore:** almacenamiento de información en la nube.
- **Git y GitHub:** control de versiones y alojamiento del código fuente.
- **GitHub Actions:** automatización del análisis y ejecución de pruebas.

## ✨ Funcionalidades

- Registro de usuarios.
- Inicio de sesión.
- Autenticación mediante Firebase.
- Gestión de información de usuarios.
- Herramientas de apoyo al estudio.
- Interfaz desarrollada con Flutter.

## 🧪 Pruebas automatizadas

El proyecto cuenta con **10 pruebas automatizadas** organizadas en dos grupos:

| Grupo | Cantidad |
|---|---:|
| Validación del registro | 5 |
| Validación del inicio de sesión | 5 |
| **Total** | **10** |

Las pruebas verifican campos vacíos, correos inválidos, contraseñas cortas y datos válidos, entre otros casos.

Se utiliza el patrón **Arrange – Act – Assert (AAA)** para organizar cada prueba.

Para ejecutar las pruebas localmente:

```bash
flutter test
```

## ⚙️ Integración continua (CI/CD)

StudyAI utiliza GitHub Actions para ejecutar automáticamente un flujo de integración continua cuando se realizan cambios en la rama `main` o se abre un Pull Request hacia ella.

El flujo realiza las siguientes actividades:

1. Obtiene el código del repositorio.
2. Configura Java.
3. Configura Flutter.
4. Instala las dependencias.
5. Analiza el código mediante `flutter analyze`.
6. Ejecuta las pruebas automatizadas mediante `flutter test`.

### Ejecutar el análisis manualmente

```bash
flutter analyze
```

### Ejecutar las pruebas manualmente

```bash
flutter test
```

## 💻 Instalación del proyecto

1. Clonar el repositorio:

```bash
git clone https://github.com/mikhailfernandez333-dot/StudyAI.git
```

2. Entrar en la carpeta:

```bash
cd StudyAI
```

3. Instalar las dependencias:

```bash
flutter pub get
```

4. Configurar Firebase con la configuración correspondiente al proyecto.

5. Ejecutar la aplicación:

```bash
flutter run
```

## 📁 Estructura del proyecto

```text
studyai/
├── .github/
│   └── workflows/
│       └── ci.yml
├── android/
├── ios/
├── lib/
│   ├── screens/
│   ├── services/
│   └── utils/
├── test/
│   ├── auth_validators_test.dart
│   └── login_validators_test.dart
├── pubspec.yaml
└── README.md
```

## 👨‍💻 Autoría

Proyecto académico desarrollado utilizando Flutter y Firebase.

**Repositorio:** https://github.com/mikhailfernandez333-dot/StudyAI

---

*StudyAI – Herramientas digitales para apoyar el aprendizaje.*