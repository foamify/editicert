use nalgebra::{Matrix4, Point3};

#[derive(Debug, Clone, Copy)]
pub struct CanvasPoint {
    pub x: f64,
    pub y: f64,
}

pub fn is_two_lines_intersecting(line1: Line, line2: Line) -> bool {
    let Line { p1, p2 } = line1;
    let Line { p1: p3, p2: p4 } = line2;
    let t = ((p1.x - p3.x) * (p3.y - p4.y) - (p1.y - p3.y) * (p3.x - p4.x))
        / ((p1.x - p2.x) * (p3.y - p4.y) - (p1.y - p2.y) * (p3.x - p4.x));
    let u = ((p1.x - p3.x) * (p1.y - p2.y) - (p1.y - p3.y) * (p1.x - p2.x))
        / ((p1.x - p2.x) * (p3.y - p4.y) - (p1.y - p2.y) * (p3.x - p4.x));

    0.0 <= t && t <= 1.0 && 0.0 <= u && u <= 1.0
}

#[derive(Debug, Clone, Copy)]
pub struct Line {
    pub p1: CanvasPoint,
    pub p2: CanvasPoint,
}

#[derive(Debug, Clone)]
pub struct Polygon {
    pub id: String,
    pub lines: Vec<Line>,
}

pub struct MarqueeRect {
    pub x: f64,
    pub y: f64,
    pub width: f64,
    pub height: f64,
}

impl MarqueeRect {
    pub fn contains_point(&self, point: CanvasPoint) -> bool {
        self.x <= point.x
            && point.x <= self.x + self.width
            && self.y <= point.y
            && point.y <= self.y + self.height
    }

    pub fn lines(&self) -> Vec<Line> {
        vec![
            Line {
                p1: CanvasPoint {
                    x: self.x,
                    y: self.y,
                },
                p2: CanvasPoint {
                    x: self.x + self.width,
                    y: self.y,
                },
            },
            Line {
                p1: CanvasPoint {
                    x: self.x + self.width,
                    y: self.y,
                },
                p2: CanvasPoint {
                    x: self.x + self.width,
                    y: self.y + self.height,
                },
            },
            Line {
                p1: CanvasPoint {
                    x: self.x + self.width,
                    y: self.y + self.height,
                },
                p2: CanvasPoint {
                    x: self.x,
                    y: self.y + self.height,
                },
            },
            Line {
                p1: CanvasPoint {
                    x: self.x,
                    y: self.y + self.height,
                },
                p2: CanvasPoint {
                    x: self.x,
                    y: self.y,
                },
            },
        ]
    }
}

trait TraitName {
    fn to_scene(&self, point: CanvasPoint) -> CanvasPoint;
    fn from_scene(&self, point: CanvasPoint) -> CanvasPoint;
}

impl TraitName for Matrix4<f64> {
    fn to_scene(&self, point: CanvasPoint) -> CanvasPoint {
        let inverse_matrix = self.try_inverse().unwrap();
        let point = Point3::new(point.x, point.y, 0.0);
        let untransformed = inverse_matrix.transform_point(&point);
        CanvasPoint {
            x: untransformed.x,
            y: untransformed.y,
        }
    }

    fn from_scene(&self, point: CanvasPoint) -> CanvasPoint {
        let untransformed = self.transform_point(&Point3::new(point.x, point.y, 0.0));
        CanvasPoint {
            x: untransformed.x,
            y: untransformed.y,
        }
    }
}

pub fn get_intersecting_ids(
    rect: MarqueeRect,
    polygons: Vec<Polygon>,
    matrix_storage: Vec<f64>,
) -> Vec<String> {
    let mut intersecting_ids = vec![];

    let matrix = Matrix4::from_vec(matrix_storage);

    for polygon in polygons {
        let mut is_break = false;
        for line in &polygon.lines {
            if rect.contains_point(matrix.from_scene(line.p1))
            {
                intersecting_ids.push(polygon.id.clone());
                is_break = true;
            }
            if is_break {
                break;
            }
            for rect_line in rect
                .lines()
                .iter()
                .map(|l| Line {
                    p1: matrix.to_scene(l.p1),
                    p2: matrix.to_scene(l.p2),
                })
                .collect::<Vec<Line>>()
            {
                if is_break {
                    break;
                }
                if is_two_lines_intersecting(*line, rect_line) {
                    intersecting_ids.push(polygon.id.clone());
                    is_break = true;
                }
            }
        }
    }

    intersecting_ids
}
