from django.urls import include, path  # noqa: F401
from rest_framework.routers import DefaultRouter
from rest_framework_nested.routers import NestedSimpleRouter  # noqa: F401

from companies import views  # noqa: F401

router = DefaultRouter()
# router.register(r'quizzes', QuizViewSet, basename='quiz')  # Прибираємо реєстрацію

urlpatterns = [
    # path('some-endpoint/', some_view),  # Якщо є інші ендпоінти
]

urlpatterns += router.urls
