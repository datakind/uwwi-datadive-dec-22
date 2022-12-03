from django.shortcuts import render

# Create your views here.

def show_map(request):
    template = "getsites/index.html"
    
    context = {"data": "Hello!"}

    return render(request, template, context)
