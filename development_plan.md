# План разработки приложения Autoservice (Flutter)

Этот документ описывает план разработки мобильного приложения Autoservice с использованием Flutter, основываясь на предоставленных API эндпоинтах.

## 1. Настройка проекта Flutter

*   Инициализация нового проекта Flutter.
*   Настройка базовой структуры папок (например, `lib/src`, `lib/features`, `lib/core`).
*   Добавление необходимых зависимостей (http, provider/riverpod, etc.).

## 2. Модуль аутентификации

*   **Эндпоинты:**
    *   `POST {{base_url}}/auth/login`
    *   `POST {{base_url}}/auth/register`
*   **Задачи:**
    *   Создание экранов входа и регистрации.
    *   Реализация логики отправки запросов на сервер для входа и регистрации.
    *   Обработка ответов сервера (успех/ошибка).
    *   Сохранение токена аутентификации (например, `j5A4AFRafOqg6X8Roe-uhcSZS-2VGpX1`) после успешного входа.
    *   Управление состоянием аутентификации пользователя.

## 3. Модуль данных (Бренды, Модели, Сообщения, Регионы)

*   **Эндпоинты:**
    *   `GET {{base_url}}/brands` (требует Bearer token)
    *   `GET {{base_url}}/brands?page=2` (требует Bearer token)
    *   `GET {{base_url}}/models` (требует Bearer token)
    *   `GET {{base_url}}/messages`
    *   `GET {{base_url}}/regions` (требует Bearer token)
    *   `GET {{base_url}}/services` (требует Bearer token)
    *   `GET {{base_url}}/service-categories` (требует Bearer token)
    *   `GET {{base_url}}/source-messages`
    *   `POST {{base_url}}/source-messages` (создание, body: raw JSON)
    *   `PUT {{base_url}}/source-messages/{id}` (обновление, body: raw JSON)
*   **Задачи:**
    *   Создание моделей данных для `Brand`, `Model`, `Message`, `Region`, `Service`, `ServiceCategory`, `SourceMessage`.
    *   Реализация сервиса для взаимодействия с API (отправка GET, POST, PUT запросов с Bearer token, включая категории услуг и исходные сообщения).
    *   Создание экранов или виджетов для отображения списков брендов, моделей, сообщений, услуг и регионов.
    *   Обработка пагинации для эндпоинта `/brands`.
    *   Отображение данных пользователю.
    *   Реализация функционала создания и обновления исходных сообщений (если применимо в UI).

## 4. Модуль Партнеры

*   **Эндпоинты:**
    *   `GET {{base_url}}/partners` (требует Bearer token)
    *   `POST {{base_url}}/partners` (создание, требует Bearer token, body: form-data)
    *   `POST {{base_url}}/partners/edit/{id}` (редактирование, требует Bearer token, body: form-data)
*   **Задачи:**
    *   Создание модели данных для `Partner`.
    *   Реализация сервиса для взаимодействия с API (GET, POST запросы с Bearer token и form-data).
    *   Создание экранов или виджетов для отображения списка партнеров, создания и редактирования партнера.
    *   Обработка ответов сервера.

## 5. Модуль Услуги Партнеров

*   **Эндпоинты:**
    *   `GET {{base_url}}/partner-services` (требует Bearer token)
    *   `POST {{base_url}}/partner-services` (создание, требует Bearer token, body: raw JSON)
    *   `PUT {{base_url}}/partner-services/{id}` (обновление, требует Bearer token, body: raw JSON)
    *   `DELETE {{base_url}}/partner-services/{id}` (удаление, требует Bearer token)
*   **Задачи:**
    *   Создание модели данных для `PartnerService`.
    *   Реализация сервиса для получения, создания, обновления и удаления услуг партнеров.
    *   Отображение данных пользователю (возможно, в деталях партнера или отдельным списком).
    *   Обработка ответов сервера.

## 6. Модуль Рабочее время партнеров

*   **Эндпоинты:**
    *   `GET {{base_url}}/partner-work-times` (требует Bearer token)
    *   `POST {{base_url}}/partner-work-times` (создание, требует Bearer token, body: raw JSON)
    *   `PUT {{base_url}}/partner-work-times/{id}` (обновление, требует Bearer token, body: raw JSON)
    *   `DELETE {{base_url}}/partner-work-times/{id}` (удаление, требует Bearer token)
*   **Задачи:**
    *   Создание модели данных для `PartnerWorkTime`.
    *   Реализация сервиса для получения, создания, обновления и удаления рабочего времени партнеров.
    *   Отображение данных пользователю (возможно, в деталях партнера).
    *   Обработка ответов сервера.

## 7. Модуль Автомобили пользователей

*   **Эндпоинты:**
    *   `GET {{base_url}}/user-cars` (требует Bearer token)
    *   `POST {{base_url}}/user-cars` (создание, требует Bearer token, body: raw JSON)
    *   `PUT {{base_url}}/user-cars/{id}` (обновление, требует Bearer token, body: raw JSON)
    *   `DELETE {{base_url}}/user-cars/{id}` (удаление, требует Bearer token)
*   **Задачи:**
    *   Создание модели данных для `UserCar`.
    *   Реализация сервиса для получения, создания, обновления и удаления автомобилей пользователя.
    *   Создание экранов или виджетов для отображения списка автомобилей пользователя, добавления и редактирования автомобиля.
    *   Обработка ответов сервера.

## 8. Модуль Заявки пользователей

*   **Эндпоинты:**
    *   `GET {{base_url}}/user-requests/user` (требует Bearer token)
    *   `POST {{base_url}}/user-requests` (создание, требует Bearer token, body: raw JSON)
    *   `PUT {{base_url}}/user-requests/{id}` (обновление, требует Bearer token, body: raw JSON)
    *   `DELETE {{base_url}}/user-requests/{id}` (удаление, требует Bearer token)
    *   `GET {{base_url}}/user-requests/partner/{partner_id}` (требует Bearer token)
*   **Задачи:**
    *   Создание модели данных для `UserRequest`.
    *   Реализация сервиса для получения, создания, обновления и удаления заявок пользователя.
    *   Создание экранов или виджетов для отображения списка заявок, создания и редактирования заявки.
    *   Обработка ответов сервера.

## 9. Управление состоянием

*   Выбор и интеграция решения для управления состоянием (например, Provider, Riverpod, Bloc).
*   Управление состоянием аутентификации, загрузки данных и пользовательского интерфейса.

## 10. Сетевое взаимодействие

*   Настройка HTTP клиента (например, `http` или `dio`).
*   Реализация обработки ошибок сети.
*   Добавление интерцепторов для автоматического добавления Bearer token к защищенным запросам.

## 11. Дальнейшие шаги

*   Ожидание дополнительной информации об API эндпоинтах для расширения функциональности.
*   Реализация UI/UX согласно дизайну (если есть).
*   Написание тестов.

### Категории Услуг

*   **Получить список категорий услуг:**
    *   `GET {{base_url}}/service-categories`
    *   Требует: Bearer token
    *   Пример ответа:
        ```json
        [
            {
                "id": 1,
                "name_ru": "Диагностика",
                "parent": null,
                "active": 1
            },
            {
                "id": 2,
                "name_ru": "Замена ABS",
                "parent": null,
                "active": 1
            },
            // ... (другие категории)
            {
                "id": 20,
                "name_ru": "Ремонт тормозной системы",
                "parent": null,
                "active": 1
            }
        ]
        ```

### Исходные сообщения (Локализация)

*   **Получить исходные сообщения:**
    *   `GET {{base_url}}/source-messages`
    *   Пример ответа:
        ```json
        [
            {
                "id": 1,
                "category": "backend",
                "message": "You have {num} log items"
            },
            {
                "id": 2,
                "category": "backend",
                "message": "View all"
            },
            // ... (другие сообщения)
            {
                "id": 20,
                "category": "backend",
                "message": "Translations"
            }
        ]
        ```
*   **Создать исходное сообщение:**
    *   `POST {{base_url}}/source-messages`
    *   Body (raw JSON):
        ```json
        {
            "category": "backend",
            "message": "Salom"
        }
        ```
*   **Обновить исходное сообщение (ID=1):**
    *   `PUT {{base_url}}/source-messages/1`
    *   Body (raw JSON):
        ```json
        {
            "category": "backend",
            "message": "You have {num} log items"
        }
        ```

*(Этот план будет дополняться по мере поступления новой информации)*

### Заявки пользователей

*   **Получить список заявок пользователя:**
    *   `GET {{base_url}}/user-requests/user`
    *   Требует: Bearer token
    *   Пример ответа:
        ```json
        [
            {
                "id": 1,
                "user_id": 6,
                "car_id": 1,
                "partner_id": 1,
                "partner_service_id": 2,
                "visit_day": "0000-00-00",
                "visit_time": "13:00:00",
                "comment": "Salom3",
                "status": 0
            },
            {
                "id": 4,
                "user_id": 6,
                "car_id": 1,
                "partner_id": 1,
                "partner_service_id": 2,
                "visit_day": "0000-00-00",
                "visit_time": "10:00:00",
                "comment": "Salom",
                "status": 0
            }
        ]
        ```

*   **Создать заявку пользователя:**
    *   `POST {{base_url}}/user-requests`
    *   Требует: Bearer token
    *   Body (raw JSON):
        ```json
        {
            "car_id": 1,
            "partner_id": 1,
            "partner_service_id": 2,
            "visit_day": "25.04.2025",
            "visit_time": "10:00",
            "comment": "Salom"
        }
        ```
*   **Обновить заявку пользователя (ID={id}):**
    *   `PUT {{base_url}}/user-requests/{id}`
    *   Требует: Bearer token
    *   Body (raw JSON):
        ```json
        {
            "car_id": 1,
            "partner_id": 1,
            "partner_service_id": 2,
            "visit_day": "23.04.2025",
            "visit_time": "13:00",
            "comment": "Salom3"
        }
        ```
*   **Удалить заявку пользователя (ID={id}):**
    *   `DELETE {{base_url}}/user-requests/{id}`
    *   Требует: Bearer token

*   **Получить список заявок для партнера (partner_id={partner_id}):**
    *   `GET {{base_url}}/user-requests/partner/{partner_id}`
    *   Требует: Bearer token
    *   Пример ответа:
        ```json
        [
            {
                "id": 1,
                "user_id": 6,
                "car_id": 1,
                "partner_id": 1,
                "partner_service_id": 2,
                "visit_day": "0000-00-00",
                "visit_time": "13:00:00",
                "comment": "Salom3",
                "status": 0
            },
            {
                "id": 2,
                "user_id": null,
                "car_id": 1,
                "partner_id": 1,
                "partner_service_id": 2,
                "visit_day": "0000-00-00",
                "visit_time": "10:00:00",
                "comment": "Salom",
                "status": 0
            },
            {
                "id": 3,
                "user_id": null,
                "car_id": 1,
                "partner_id": 1,
                "partner_service_id": 2,
                "visit_day": "0000-00-00",
                "visit_time": "10:00:00",
                "comment": "Salom",
                "status": 0
            },
            {
                "id": 4,
                "user_id": 6,
                "car_id": 1,
                "partner_id": 1,
                "partner_service_id": 2,
                "visit_day": "0000-00-00",
                "visit_time": "10:00:00",
                "comment": "Salom",
                "status": 0
            }
        ]
        ```

### Автомобили пользователей

*   **Получить список автомобилей пользователя:**
    *   `GET {{base_url}}/user-cars`
    *   Требует: Bearer token
    *   Пример ответа:
        ```json
        [
            {
                "id": 1,
                "user_id": 6,
                "brand_id": 2,
                "model_id": 4,
                "prod_year": "0000",
                "color": "Salom2",
                "gear": "Salom2",
                "gov_number": "Salo2",
                "fuel_type": "Sal2om"
            }
        ]
        ```

*   **Создать автомобиль пользователя:**
    *   `POST {{base_url}}/user-cars`
    *   Требует: Bearer token
    *   Body (raw JSON):
        ```json
        {
            "brand_id": 2,
            "model_id": 4,
            "prod_year": "Salom",
            "color": "Salom",
            "gear": "Salom",
            "gov_number": "Salom",
            "fuel_type": "Salom"
        }
        ```
*   **Обновить автомобиль пользователя (ID=1):**
    *   `PUT {{base_url}}/user-cars/1`
    *   Требует: Bearer token
    *   Body (raw JSON):
        ```json
        {
            "brand_id": 2,
            "model_id": 4,
            "prod_year": "Salom ww",
            "color": "Salom2",
            "gear": "Salom2",
            "gov_number": "Salo2",
            "fuel_type": "Sal2om"
        }
        ```
*   **Удалить автомобиль пользователя (ID=2):**
    *   `DELETE {{base_url}}/user-cars/2`
    *   Требует: Bearer token

## Детали API эндпоинтов

### Аутентификация

*   **Login:**
    *   `POST {{base_url}}/auth/login`
    *   Body:
        ```json
        {
            "username": "alexqwert2",
            "password": "fytrljnW2"
        }
        ```
*   **Register:**
    *   `POST {{base_url}}/auth/register`
    *   Body:
        ```json
        {
            "username": "alexqwert2",
            "password": "fytrljnW2",
            "phone": "881090052",
            "firstname": "Anvar"
        }
        ```

### Бренды

*   **Получить список брендов (страница 1):**
    *   `GET {{base_url}}/brands`
    *   Требует: Bearer token (Пример: `j5A4AFRafOqg6X8Roe-uhcSZS-2VGpX1`)
    *   Пример ответа:
        ```json
        [
            {
                "id": 2,
                "name_ru": "Chevrolet",
                "name_oz": "Chevrolet",
                "name_en": "Chevrolet",
                "logo": null
            },
            // ... (другие бренды)
            {
                "id": 21,
                "name_ru": "Nio",
                "name_oz": "Nio",
                "name_en": "Nio",
                "logo": null
            }
        ]
        ```

*   **Получить список брендов (страница 2):**
    *   `GET {{base_url}}/brands?page=2`
    *   Требует: Bearer token
    *   Ответ: Аналогичен первой странице.

### Модели

*   **Получить список моделей:**
    *   `GET {{base_url}}/models`
    *   Требует: Bearer token
    *   Пример ответа:
        ```json
        [
            {
                "id": 4,
                "brand_id": 3,
                "name_ru": "100",
                "name_oz": "100",
                "name_en": "100"
            },
            {
                "id": 5,
                "brand_id": 3,
                "name_ru": "200",
                "name_oz": "200",
                "name_en": "200"
            },
            {
                "id": 6,
                "brand_id": 3,
                "name_ru": "80",
                "name_oz": "80",
                "name_en": "80"
            }
        ]
        ```

### Партнеры

*   **Получить список партнеров:**
    *   `GET {{base_url}}/partners`
    *   Требует: Bearer token
    *   Пример ответа:
        ```json
        [
            {
                "id": 1,
                "name": "New Partner Name",
                "description": "description text",
                "logo": null,
                "adress": "address text",
                "region": 1703202558,
                "location": "69.279737:41.311151",
                "phone": "881090055",
                "status": 0
            },
            {
                "id": 2,
                "name": "New Partner Name",
                "description": "description text",
                "logo": null,
                "adress": "address text",
                "region": 1703202558,
                "location": "69.279737:41.311151",
                "phone": "881090055",
                "status": 0
            },
            {
                "id": 3,
                "name": "New Partner Name 2",
                "description": "description text 2",
                "logo": "uploads/_file65489b0868a35-favicon1744085547.png",
                "adress": "address text2",
                "region": 1703202558,
                "location": "69.279737:41.311151",
                "phone": "881090055",
                "status": 0
            }
        ]
        ```

*   **Создать партнера:**
    *   `POST {{base_url}}/partners`
    *   Требует: Bearer token
    *   Body (form-data):
        *   `name`: New Partner Name
        *   `description`: description text
        *   `adress`: address text
        *   `region`: 1703202558
        *   `location`: 69.279737:41.311151
        *   `phone`: 881090055
*   **Редактировать партнера (ID=3):**
    *   `POST {{base_url}}/partners/edit/3`
    *   Требует: Bearer token
    *   Body (form-data):
        *   `name`: New Partner Name 2
        *   `description`: description text 2
        *   `adress`: address text2
        *   `region`: 1703202558
        *   `location`: 69.279737:41.311151
        *   `phone`: 881090055

### Услуги Партнеров

*   **Получить список услуг партнеров:**
    *   `GET {{base_url}}/partner-services`
    *   Требует: Bearer token
    *   Пример ответа:
        ```json
        [
            {
                "id": 2,
                "partner_id": 1,
                "brand_id": 2,
                "model_id": 4,
                "service_id": 1,
                "price": null,
                "status": 0
            }
        ]
        ```

*   **Создать услугу партнера:**
    *   `POST {{base_url}}/partner-services`
    *   Требует: Bearer token
    *   Body (raw JSON):
        ```json
        {
            "partner_id": 1,
            "brand_id": 2,
            "model_id": 4,
            "service_id": 1,
            "price": 123123
        }
        ```
*   **Обновить услугу партнера (ID=1):**
    *   `PUT {{base_url}}/partner-services/1`
    *   Требует: Bearer token
    *   Body (raw JSON):
        ```json
        {
            "partner_id": 1,
            "brand_id": 2,
            "model_id": 4,
            "service_id": 1,
            "price": 11222
        }
        ```
*   **Удалить услугу партнера (ID=2):**
    *   `DELETE {{base_url}}/partner-services/2`
    *   Требует: Bearer token

### Рабочее время партнеров

*   **Получить рабочее время партнера:**
    *   `GET {{base_url}}/partner-work-times`
    *   Требует: Bearer token
    *   Пример ответа:
        ```json
        [
            {
                "id": 2,
                "partner_id": 1,
                "week_day": "sunday",
                "begin": "9:00",
                "end": "18:00",
                "break_begin": "13:00",
                "break_end": "14:00"
            }
        ]
        ```

*   **Создать рабочее время партнера:**
    *   `POST {{base_url}}/partner-work-times`
    *   Требует: Bearer token
    *   Body (raw JSON):
        ```json
        {
            "partner_id": 1,
            "week_day": "monday",
            "begin": "9:00",
            "end": "18:00",
            "break_begin": "13:00",
            "break_end": "14:00"
        }
        ```
*   **Обновить рабочее время партнера (ID=2):**
    *   `PUT {{base_url}}/partner-work-times/2`
    *   Требует: Bearer token
    *   Body (raw JSON):
        ```json
        {
            "partner_id": 1,
            "week_day": "sunday",
            "begin": "9:00",
            "end": "18:00",
            "break_begin": "13:00",
            "break_end": "14:00"
        }
        ```
*   **Удалить рабочее время партнера (ID=1):**
    *   `DELETE {{base_url}}/partner-work-times/1`
    *   Требует: Bearer token

### Сообщения/Локализация

*   **Получить сообщения:**
    *   `GET {{base_url}}/messages`
    *   Пример ответа:
        ```json
        [
            {
                "id": 1,
                "language": "en-US",
                "translation": "You have {num} log items2"
            },
            {
                "id": 1,
                "language": "ru-RU",
                "translation": "У вас имеется {num} сообщений"
            },
            // ... (другие сообщения)
            {
                "id": 7,
                "language": "ru-RU",
                "translation": "Время регистрации"
            }
        ]
        ```

### Регионы

*   **Получить список регионов:**
    *   `GET {{base_url}}/regions`
    *   Требует: Bearer token
    *   Пример ответа:
        ```json
        [
            {
                "id": 20287,
                "name_ru": "Андижанская область",
                "name_uz": "Андижон вилояти",
                "name_oz": "Andijon viloyati",
                "name_en": null,
                "name_short": null,
                "parent": null,
                "otype": 2,
                "soato": 1703,
                "lat_c": 40.75,
                "long_c": 72.1667,
                "position": 900,
                "sort": null,
                "status": null
            },
            {
                "id": 20289,
                "name_ru": "Алтынкульский район",
                "name_uz": "Олтинкўл тумани",
                "name_oz": "Oltinko'l tumani",
                "name_en": null,
                "name_short": null,
                "parent": null,
                "otype": 3,
                "soato": 1703202,
                "lat_c": 40.7,
                "long_c": 72.1667,
                "position": 900,
                "sort": null,
                "status": null
            },
            // ... (другие регионы)
        ]
        ```

### Категории Услуг

*   **Получить список категорий услуг:**
    *   `GET {{base_url}}/service-categories`
    *   Требует: Bearer token
    *   Пример ответа:
        ```json
        [
            {
                "id": 1,
                "name_ru": "Диагностика",
                "parent": null,
                "active": 1
            },
            {
                "id": 2,
                "name_ru": "Замена ABS",
                "parent": null,
                "active": 1
            },
            // ... (другие категории)
            {
                "id": 20,
                "name_ru": "Ремонт тормозной системы",
                "parent": null,
                "active": 1
            }
        ]
        ```

*(Этот план будет дополняться по мере поступления новой информации)*

### Заявки пользователей

*   **Получить список заявок пользователя:**
    *   `GET {{base_url}}/user-requests/user`
    *   Требует: Bearer token
    *   Пример ответа:
        ```json
        [
            {
                "id": 1,
                "user_id": 6,
                "car_id": 1,
                "partner_id": 1,
                "partner_service_id": 2,
                "visit_day": "0000-00-00",
                "visit_time": "13:00:00",
                "comment": "Salom3",
                "status": 0
            },
            {
                "id": 4,
                "user_id": 6,
                "car_id": 1,
                "partner_id": 1,
                "partner_service_id": 2,
                "visit_day": "0000-00-00",
                "visit_time": "10:00:00",
                "comment": "Salom",
                "status": 0
            }
        ]
        ```

*   **Создать заявку пользователя:**
    *   `POST {{base_url}}/user-requests`
    *   Требует: Bearer token
    *   Body (raw JSON):
        ```json
        {
            "car_id": 1,
            "partner_id": 1,
            "partner_service_id": 2,
            "visit_day": "25.04.2025",
            "visit_time": "10:00",
            "comment": "Salom"
        }
        ```
*   **Обновить заявку пользователя (ID={id}):**
    *   `PUT {{base_url}}/user-requests/{id}`
    *   Требует: Bearer token
    *   Body (raw JSON):
        ```json
        {
            "car_id": 1,
            "partner_id": 1,
            "partner_service_id": 2,
            "visit_day": "23.04.2025",
            "visit_time": "13:00",
            "comment": "Salom3"
        }
        ```
*   **Удалить заявку пользователя (ID={id}):**
    *   `DELETE {{base_url}}/user-requests/{id}`
    *   Требует: Bearer token

*   **Получить список заявок для партнера (partner_id={partner_id}):**
    *   `GET {{base_url}}/user-requests/partner/{partner_id}`
    *   Требует: Bearer token
    *   Пример ответа:
        ```json
        [
            {
                "id": 1,
                "user_id": 6,
                "car_id": 1,
                "partner_id": 1,
                "partner_service_id": 2,
                "visit_day": "0000-00-00",
                "visit_time": "13:00:00",
                "comment": "Salom3",
                "status": 0
            },
            {
                "id": 2,
                "user_id": null,
                "car_id": 1,
                "partner_id": 1,
                "partner_service_id": 2,
                "visit_day": "0000-00-00",
                "visit_time": "10:00:00",
                "comment": "Salom",
                "status": 0
            },
            {
                "id": 3,
                "user_id": null,
                "car_id": 1,
                "partner_id": 1,
                "partner_service_id": 2,
                "visit_day": "0000-00-00",
                "visit_time": "10:00:00",
                "comment": "Salom",
                "status": 0
            },
            {
                "id": 4,
                "user_id": 6,
                "car_id": 1,
                "partner_id": 1,
                "partner_service_id": 2,
                "visit_day": "0000-00-00",
                "visit_time": "10:00:00",
                "comment": "Salom",
                "status": 0
            }
        ]
        ```

### Автомобили пользователей

*   **Получить список автомобилей пользователя:**
    *   `GET {{base_url}}/user-cars`
    *   Требует: Bearer token
    *   Пример ответа:
        ```json
        [
            {
                "id": 1,
                "user_id": 6,
                "brand_id": 2,
                "model_id": 4,
                "prod_year": "0000",
                "color": "Salom2",
                "gear": "Salom2",
                "gov_number": "Salo2",
                "fuel_type": "Sal2om"
            }
        ]
        ```

*   **Создать автомобиль пользователя:**
    *   `POST {{base_url}}/user-cars`
    *   Требует: Bearer token
    *   Body (raw JSON):
        ```json
        {
            "brand_id": 2,
            "model_id": 4,
            "prod_year": "Salom",
            "color": "Salom",
            "gear": "Salom",
            "gov_number": "Salom",
            "fuel_type": "Salom"
        }
        ```
*   **Обновить автомобиль пользователя (ID=1):**
    *   `PUT {{base_url}}/user-cars/1`
    *   Требует: Bearer token
    *   Body (raw JSON):
        ```json
        {
            "brand_id": 2,
            "model_id": 4,
            "prod_year": "Salom ww",
            "color": "Salom2",
            "gear": "Salom2",
            "gov_number": "Salo2",
            "fuel_type": "Sal2om"
        }
        ```
*   **Удалить автомобиль пользователя (ID=2):**
    *   `DELETE {{base_url}}/user-cars/2`
    *   Требует: Bearer token

### Услуги

*   **Получить список услуг:**
    *   `GET {{base_url}}/services`
    *   Требует: Bearer token
    *   Пример ответа:
        ```json
        [
            {
                "id": 1,
                "name_ru": "Диагностика ABS",
                "category": 1,
                "price": "от 800 руб."
            },
            {
                "id": 2,
                "name_ru": "Диагностика Common Rail",
                "category": 1,
                "price": "от 900 руб."
            },
            // ... (другие услуги)
            {
                "id": 20,
                "name_ru": "Диагностика подвески",
                "category": 1,
                "price": "от 900 руб."
            }
        ]
        ```

### Исходные сообщения (Локализация)

*   **Получить исходные сообщения:**
    *   `GET {{base_url}}/source-messages`
    *   Пример ответа:
        ```json
        [
            {
                "id": 1,
                "category": "backend",
                "message": "You have {num} log items"
            },
            {
                "id": 2,
                "category": "backend",
                "message": "View all"
            },
            // ... (другие сообщения)
            {
                "id": 20,
                "category": "backend",
                "message": "Translations"
            }
        ]
        ```
*   **Создать исходное сообщение:**
    *   `POST {{base_url}}/source-messages`
    *   Body (raw JSON):
        ```json
        {
            "category": "backend",
            "message": "Salom"
        }
        ```
*   **Обновить исходное сообщение (ID=1):**
    *   `PUT {{base_url}}/source-messages/1`
    *   Body (raw JSON):
        ```json
        {
            "category": "backend",
            "message": "You have {num} log items"
        }
        ```