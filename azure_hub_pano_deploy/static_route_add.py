#!/usr/bin/env python

# Copyright (c) 2019 Brad Atkinson <brad.scripting@gmail.com>
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

import re
import json
import pan_module as pa


def nexthop_ip(pano, base_xpath, static_route_name, nexthop, interface,
               destination):
    """
    Sets static route with a nexthop IP

    Parameters
    ----------
    pano : Panorama
        A PanDevice for Panorama
    base_xpath : str
        The initial API command for the virtual router
    static_route_name : str
        The name of the static route
    nexthop : str
        The IP address of the next hop
    interface : str
        The outgoing interface
    destination : str
        The route IP address and netmask
    """
    entry_element = ('<entry name="{}"><path-monitor><enable>no</enable>'
                     '<failure-condition>any</failure-condition><hold-time>2'
                     '</hold-time></path-monitor><nexthop><ip-address>{}'
                     '</ip-address></nexthop><bfd><profile>None</profile>'
                     '</bfd><interface>{}</interface><metric>10'
                     '</metric><destination>{}</destination><route-table>'
                     '<unicast/></route-table></entry>'
                     .format(static_route_name, nexthop, interface, destination))
    pano.xapi.set(xpath=base_xpath, element=entry_element)


def nexthop_vr(pano, base_xpath, static_route_name, nexthop, destination):
    """
    Sets static route with a nexthop VR

    Parameters
    ----------
    pano : Panorama
        A PanDevice for Panorama
    base_xpath : str
        The initial API command for the virtual router
    static_route_name : str
        The name of the static route
    nexthop : str
        The VR of the next hop
    destination : str
        The route IP address and netmask
    """
    entry_element = ('<entry name="{}"><path-monitor><enable>no</enable>'
                     '<failure-condition>any</failure-condition><hold-time>2'
                     '</hold-time></path-monitor><nexthop><next-vr>{}'
                     '</next-vr></nexthop><bfd><profile>None</profile></bfd>'
                     '<metric>10</metric><destination>{}</destination>'
                     '<route-table><unicast/></route-table></entry>'
                     .format(static_route_name, nexthop, destination))
    pano.xapi.set(xpath=base_xpath, element=entry_element)


def main():
    """
    Get active Panorama connection, load static routes JSON file to dictionary,
    and verify if the next hop is either an IP address or virtual router
    """
    pano = pa.get_active_pano()

    with open('static_routes.json', 'r') as json_file:
        static_routes_dict = json.load(json_file)

    ip_regex = r"(((?:(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3})(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?))"

    for static_route_dict in static_routes_dict.values():
        template_name = static_route_dict.get('template')
        virtual_router_name = static_route_dict.get('virtual_router')
        static_route_name = static_route_dict.get('name')
        destination = static_route_dict.get('route')
        nexthop = static_route_dict.get('nexthop')
        interface = static_route_dict.get('interface')

        base_xpath = ("/config/devices/entry[@name='localhost.localdomain']"
                      "/template/entry[@name='{}']/config/devices/entry"
                      "[@name='localhost.localdomain']/network/virtual-router"
                      "/entry[@name='{}']/routing-table/ip/static-route"
                      .format(template_name, virtual_router_name))

        nexthop_info = re.search(ip_regex, nexthop)

        if nexthop_info is not None:
            nexthop_ip(pano, base_xpath, static_route_name, nexthop, interface,
                       destination)
        else:
            nexthop_vr(pano, base_xpath, static_route_name, nexthop,
                       destination)


if __name__ == '__main__':
    main()
