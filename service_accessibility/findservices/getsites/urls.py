from django.urls import path
from . import views

app_name = "getsites"

urlpatterns = [
  path("", views.show_map, name = "showmap"),
]
