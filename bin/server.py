# Expects python 3.10.
# Probably works fine with adjacent versions, but I haven't tested.
import http.server
import socketserver
import os

PORT = 8000

web_dir = web_dir = os.path.join(os.path.dirname(__file__), '../export/web')
os.chdir(web_dir)

class MyHTTPRequestHandler(http.server.SimpleHTTPRequestHandler):
    def end_headers(self):
        self.send_header('Cross-Origin-Opener-Policy', 'same-origin')
        self.send_header('Cross-Origin-Embedder-Policy', 'require-corp')
        super().end_headers()

with socketserver.TCPServer(("", PORT), MyHTTPRequestHandler) as httpd:
    print(f"Serving at port {PORT}")
    httpd.serve_forever()