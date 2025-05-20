from os.path import join as path_join, dirname

from flask import Flask, send_from_directory

from sippy.UI.Controller import UIController

def customize(iui:UIController, make_app:callable):
    static_folder = path_join(dirname(__file__), 'static')
    partials_folder = path_join(static_folder, 'partials')
    static_url = '/webrtc_phone/static'

    def webrtc_phone():
        with open(path_join(partials_folder, 'webrtc_phone.html')) as f:
            body = f.read()
        html_pre = '<div class="webrtc-phone-box">'
        html_post = '</div>'
        style = f'<link rel="stylesheet" href="{static_url}/webrtc_phone.css">'
        content = '\n'.join((html_pre, body, html_post))
        return iui.render_page(content, style)
    def extra_static(filename):
        return send_from_directory(static_folder, filename)
    url = f'{static_url}/<path:filename>'
    iui.menu['/webrtc_phone'] = {'name':'WebRTC Phone', 'app_route': webrtc_phone, 'order':-1}
    del iui.menu['/shutdown']
    del iui.menu['/restart']
    iui.app_name = 'Sippy WebRTC Phone'
    app = make_app()
    app.add_url_rule(url, endpoint=url, view_func=extra_static, methods=['GET'])
    return app
