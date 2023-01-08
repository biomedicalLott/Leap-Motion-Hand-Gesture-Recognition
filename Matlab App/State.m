classdef State < uint32
   enumeration
      NEUTRAL (0),
      ROTATE (1),
      EXTRUDE (2),
      SCALE (3),
      CREATE (4),
      POLY_CREATE(5),
      TRANSLATE(6)
   end
end
