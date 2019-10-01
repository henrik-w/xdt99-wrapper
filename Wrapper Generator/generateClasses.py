import sys, os, locale
locale.setlocale(locale.LC_ALL, 'de_DE.UTF-8')

sys.path.insert(0, os.path.join(sys.path[0], 'objp'))
import o2p

sys.path.insert(0, os.path.join(sys.path[1], '../xdt99'))
import xas99, xga99, xbas99

outDir = os.path.join(sys.path[2], 'XDTWrapper', 'xas99')
o2p.classPrefix = 'XDTAs99'
o2p.generate_objc_code(xas99.Assembler, outDir)
o2p.generate_objc_code(xas99.Parser, outDir)

outDir = os.path.join(sys.path[2], 'XDTWrapper', 'xga99')
o2p.classPrefix = 'XDTGa99'
o2p.generate_objc_code(xga99.Assembler, outDir)

outDir = os.path.join(sys.path[2], 'XDTWrapper', 'xbas99')
o2p.classPrefix = 'XDT'
o2p.generate_objc_code(xbas99.BasicProgram, outDir)
o2p.generate_objc_code(xbas99.Tokens, outDir)
