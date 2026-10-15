"""Create the small, self-contained GLB used by the subsurface lesson (stdlib only)."""
import json
import math
from pathlib import Path
import struct


def sample():
    # A closed, smooth wax sample: 32 mm across, 6 mm thick at its centre.
    t = (1 + math.sqrt(5)) / 2
    points = [(-1,t,0),(1,t,0),(-1,-t,0),(1,-t,0),(0,-1,t),(0,1,t),
              (0,-1,-t),(0,1,-t),(t,0,-1),(t,0,1),(-t,0,-1),(-t,0,1)]
    def unit(p):
        length = math.sqrt(sum(v*v for v in p))
        return tuple(v / length for v in p)
    points = list(map(unit, points))
    faces = [(0,11,5),(0,5,1),(0,1,7),(0,7,10),(0,10,11),(1,5,9),(5,11,4),
             (11,10,2),(10,7,6),(7,1,8),(3,9,4),(3,4,2),(3,2,6),(3,6,8),(3,8,9),
             (4,9,5),(2,4,11),(6,2,10),(8,6,7),(9,8,1)]
    for _ in range(4):
        midpoints, refined = {}, []
        def midpoint(a, b):
            edge = tuple(sorted((a, b)))
            if edge not in midpoints:
                midpoints[edge] = len(points)
                points.append(unit(tuple((x+y)/2 for x,y in zip(points[a], points[b]))))
            return midpoints[edge]
        for a, b, c in faces:
            ab, bc, ca = midpoint(a,b), midpoint(b,c), midpoint(c,a)
            refined.extend(((a,ab,ca),(b,bc,ab),(c,ca,bc),(ab,bc,ca)))
        faces = refined
    axes = (.016, .003, .016)
    vertices = [v * scale for p in points for v,scale in zip(p, axes)]
    normals = [v for p in points for v in unit(tuple(v/scale for v,scale in zip(p, axes)))]
    return vertices, normals, [v for face in faces for v in face]


def main():
    blob = bytearray()
    views, accessors, meshes = [], [], []

    def accessor(values, width, component, kind):
        while len(blob) % 4:
            blob.append(0)
        offset = len(blob)
        blob.extend(struct.pack('<' + ('f' if component == 5126 else 'I') * len(values), *values))
        views.append({'buffer': 0, 'byteOffset': offset, 'byteLength': len(blob) - offset})
        record = {'bufferView': len(views) - 1, 'componentType': component,
                  'count': len(values) // width, 'type': kind}
        if kind == 'VEC3':
            record['min'] = [min(values[k::3]) for k in range(3)]
            record['max'] = [max(values[k::3]) for k in range(3)]
        accessors.append(record)
        return len(accessors) - 1

    def mesh(name, positions, normals, indices, material):
        # Author in LT's Z-up coordinates; glTF files use Y up.
        def y_up(values):
            return [v for x, y, z in zip(values[::3], values[1::3], values[2::3]) for v in (x, z, -y)]
        # LT scenes use centimetres; keep the stored coordinates and UI units consistent.
        positions, normals = [v * 100 for v in y_up(positions)], y_up(normals)
        meshes.append({'name': name, 'primitives': [{'attributes': {
            'POSITION': accessor(positions, 3, 5126, 'VEC3'),
            'NORMAL': accessor(normals, 3, 5126, 'VEC3')},
            'indices': accessor(indices, 1, 5125, 'SCALAR'), 'material': material}]})
        return len(meshes) - 1

    positions, normals, indices = sample()
    left = mesh('Opaque reference', positions, normals, indices, 0)
    right = mesh('Wax sample', positions, normals, indices, 1)
    floor = mesh('Floor', [-.2, -.2, 0, .2, -.2, 0, .2, .2, 0, -.2, .2, 0],
                 [0, 0, 1] * 4, [0, 1, 2, 0, 2, 3], 2)
    light = mesh('Softbox', [-.05, 0, 0, .05, 0, 0, .05, .05, -.04, -.05, .05, -.04],
                 [0, -.625, -.781] * 4, [0, 1, 2, 0, 2, 3], 3)
    material = lambda name: {'name': name, 'pbrMetallicRoughness': {
        'baseColorFactor': [0.8, 0.39, 0.12, 1], 'metallicFactor': 0, 'roughnessFactor': .35}}
    scene = {'asset': {'version': '2.0', 'generator': 'Light Tracer tutorials / make_sss_samples.py'},
             'scene': 0, 'scenes': [{'nodes': [0, 1, 2, 3],
                                   'extras': {'RenderSettingsLT': {'SceneUnits': 2}}}],
             'nodes': [{'name': 'Opaque reference', 'mesh': left, 'translation': [-2, 1.6, 0]},
                       {'name': 'Wax sample', 'mesh': right, 'translation': [2, 1.6, 0]},
                       {'name': 'Floor', 'mesh': floor},
                       {'name': 'Softbox', 'mesh': light, 'translation': [0, 6.5, -1]}],
             'materials': [material('Opaque'), material('Wax'),
                           {'name': 'Slate', 'pbrMetallicRoughness': {'baseColorFactor': [.035, .045, .06, 1],
                            'metallicFactor': 0, 'roughnessFactor': .5}},
                           {'name': 'Softbox', 'doubleSided': True, 'emissiveFactor': [1, 1, 1],
                            'extensions': {'KHR_materials_emissive_strength': {'emissiveStrength': 3}}}],
             'extensionsUsed': ['KHR_materials_emissive_strength'],
             'meshes': meshes, 'bufferViews': views, 'accessors': accessors,
             'buffers': [{'byteLength': len(blob)}]}
    encoded = json.dumps(scene, separators=(',', ':')).encode()
    encoded += b' ' * (-len(encoded) % 4)
    blob += b'\0' * (-len(blob) % 4)
    result = struct.pack('<III', 0x46546c67, 2, 28 + len(encoded) + len(blob))
    result += struct.pack('<II', len(encoded), 0x4e4f534a) + encoded
    result += struct.pack('<II', len(blob), 0x004e4942) + blob
    target = Path(__file__).resolve().parents[1] / 'data/tutorials/assets/sss_samples.glb'
    target.write_bytes(result)
    print(f'{target}: {len(result):,} bytes')


if __name__ == '__main__':
    main()
