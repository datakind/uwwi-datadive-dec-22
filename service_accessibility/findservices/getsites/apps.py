import os
from json import load
from django.apps import AppConfig

class GetsitesConfig(AppConfig):
    default_auto_field = "django.db.models.BigAutoField"
    name = "getsites"

    # For if we need to do anything on application startup
    def ready(self):
        pass
        
