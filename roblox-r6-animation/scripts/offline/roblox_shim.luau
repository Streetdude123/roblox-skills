local sqrt, sin, cos, abs, acos = math.sqrt, math.sin, math.cos, math.abs, math.acos

local V3 = {}
local V3mt = {}

local function vec(x, y, z)
	return setmetatable({X = x or 0, Y = y or 0, Z = z or 0}, V3mt)
end

local V3methods = {}
function V3methods.Dot(a, b)
	return a.X * b.X + a.Y * b.Y + a.Z * b.Z
end
function V3methods.Cross(a, b)
	return vec(a.Y * b.Z - a.Z * b.Y, a.Z * b.X - a.X * b.Z, a.X * b.Y - a.Y * b.X)
end
function V3methods.Lerp(a, b, t)
	return vec(a.X + (b.X - a.X) * t, a.Y + (b.Y - a.Y) * t, a.Z + (b.Z - a.Z) * t)
end
function V3methods.FuzzyEq(a, b, eps)
	eps = eps or 1e-5
	return abs(a.X - b.X) <= eps and abs(a.Y - b.Y) <= eps and abs(a.Z - b.Z) <= eps
end

V3mt.__index = function(v, k)
	if k == "Magnitude" then
		return sqrt(v.X * v.X + v.Y * v.Y + v.Z * v.Z)
	elseif k == "Unit" then
		local m = sqrt(v.X * v.X + v.Y * v.Y + v.Z * v.Z)
		if m == 0 then
			return vec(0 / 0, 0 / 0, 0 / 0)
		end
		return vec(v.X / m, v.Y / m, v.Z / m)
	end
	return V3methods[k]
end
V3mt.__add = function(a, b)
	return vec(a.X + b.X, a.Y + b.Y, a.Z + b.Z)
end
V3mt.__sub = function(a, b)
	return vec(a.X - b.X, a.Y - b.Y, a.Z - b.Z)
end
V3mt.__unm = function(a)
	return vec(-a.X, -a.Y, -a.Z)
end
V3mt.__mul = function(a, b)
	if type(a) == "number" then
		return vec(a * b.X, a * b.Y, a * b.Z)
	elseif type(b) == "number" then
		return vec(a.X * b, a.Y * b, a.Z * b)
	end
	return vec(a.X * b.X, a.Y * b.Y, a.Z * b.Z)
end
V3mt.__div = function(a, b)
	if type(b) == "number" then
		return vec(a.X / b, a.Y / b, a.Z / b)
	end
	return vec(a.X / b.X, a.Y / b.Y, a.Z / b.Z)
end
V3mt.__eq = function(a, b)
	return a.X == b.X and a.Y == b.Y and a.Z == b.Z
end
V3mt.__tostring = function(a)
	return string.format("%g, %g, %g", a.X, a.Y, a.Z)
end
V3mt.__type = "Vector3"

V3.new = vec
V3.zero = vec(0, 0, 0)
V3.one = vec(1, 1, 1)
V3.xAxis = vec(1, 0, 0)
V3.yAxis = vec(0, 1, 0)
V3.zAxis = vec(0, 0, 1)

local CF = {}
local CFmt = {}

local function cf(x, y, z, a, b, c, d, e, f, g, h, i)
	return setmetatable({x = x, y = y, z = z, a = a, b = b, c = c, d = d, e = e, f = f, g = g, h = h, i = i}, CFmt)
end

local function mul(p, q)
	return cf(
		p.a * q.x + p.b * q.y + p.c * q.z + p.x,
		p.d * q.x + p.e * q.y + p.f * q.z + p.y,
		p.g * q.x + p.h * q.y + p.i * q.z + p.z,
		p.a * q.a + p.b * q.d + p.c * q.g, p.a * q.b + p.b * q.e + p.c * q.h, p.a * q.c + p.b * q.f + p.c * q.i,
		p.d * q.a + p.e * q.d + p.f * q.g, p.d * q.b + p.e * q.e + p.f * q.h, p.d * q.c + p.e * q.f + p.f * q.i,
		p.g * q.a + p.h * q.d + p.i * q.g, p.g * q.b + p.h * q.e + p.i * q.h, p.g * q.c + p.h * q.f + p.i * q.i
	)
end

local function inverse(p)
	local a, b, c, d, e, f, g, h, i = p.a, p.d, p.g, p.b, p.e, p.h, p.c, p.f, p.i
	return cf(-(a * p.x + b * p.y + c * p.z), -(d * p.x + e * p.y + f * p.z), -(g * p.x + h * p.y + i * p.z), a, b, c, d, e, f, g, h, i)
end

local function toQuat(p)
	local t = p.a + p.e + p.i
	local w, x, y, z
	if t > 0 then
		local s = sqrt(t + 1) * 2
		w, x, y, z = 0.25 * s, (p.h - p.f) / s, (p.c - p.g) / s, (p.d - p.b) / s
	elseif p.a > p.e and p.a > p.i then
		local s = sqrt(1 + p.a - p.e - p.i) * 2
		w, x, y, z = (p.h - p.f) / s, 0.25 * s, (p.b + p.d) / s, (p.c + p.g) / s
	elseif p.e > p.i then
		local s = sqrt(1 + p.e - p.a - p.i) * 2
		w, x, y, z = (p.c - p.g) / s, (p.b + p.d) / s, 0.25 * s, (p.f + p.h) / s
	else
		local s = sqrt(1 + p.i - p.a - p.e) * 2
		w, x, y, z = (p.d - p.b) / s, (p.c + p.g) / s, (p.f + p.h) / s, 0.25 * s
	end
	return w, x, y, z
end

local function fromQuat(px, py, pz, w, x, y, z)
	local n = sqrt(w * w + x * x + y * y + z * z)
	w, x, y, z = w / n, x / n, y / n, z / n
	return cf(px, py, pz,
		1 - 2 * (y * y + z * z), 2 * (x * y - z * w), 2 * (x * z + y * w),
		2 * (x * y + z * w), 1 - 2 * (x * x + z * z), 2 * (y * z - x * w),
		2 * (x * z - y * w), 2 * (y * z + x * w), 1 - 2 * (x * x + y * y))
end

local CFmethods = {}
function CFmethods.Inverse(p)
	return inverse(p)
end
function CFmethods.GetComponents(p)
	return p.x, p.y, p.z, p.a, p.b, p.c, p.d, p.e, p.f, p.g, p.h, p.i
end
CFmethods.components = CFmethods.GetComponents
function CFmethods.ToWorldSpace(p, q)
	return mul(p, q)
end
function CFmethods.ToObjectSpace(p, q)
	return mul(inverse(p), q)
end
function CFmethods.PointToWorldSpace(p, v)
	return vec(p.a * v.X + p.b * v.Y + p.c * v.Z + p.x, p.d * v.X + p.e * v.Y + p.f * v.Z + p.y, p.g * v.X + p.h * v.Y + p.i * v.Z + p.z)
end
function CFmethods.PointToObjectSpace(p, v)
	local dx, dy, dz = v.X - p.x, v.Y - p.y, v.Z - p.z
	return vec(p.a * dx + p.d * dy + p.g * dz, p.b * dx + p.e * dy + p.h * dz, p.c * dx + p.f * dy + p.i * dz)
end
function CFmethods.VectorToWorldSpace(p, v)
	return vec(p.a * v.X + p.b * v.Y + p.c * v.Z, p.d * v.X + p.e * v.Y + p.f * v.Z, p.g * v.X + p.h * v.Y + p.i * v.Z)
end
function CFmethods.VectorToObjectSpace(p, v)
	return vec(p.a * v.X + p.d * v.Y + p.g * v.Z, p.b * v.X + p.e * v.Y + p.h * v.Z, p.c * v.X + p.f * v.Y + p.i * v.Z)
end
function CFmethods.Lerp(p, q, t)
	local w1, x1, y1, z1 = toQuat(p)
	local w2, x2, y2, z2 = toQuat(q)
	local d = w1 * w2 + x1 * x2 + y1 * y2 + z1 * z2
	if d < 0 then
		w2, x2, y2, z2, d = -w2, -x2, -y2, -z2, -d
	end
	local k1, k2
	if d > 0.9995 then
		k1, k2 = 1 - t, t
	else
		local th = acos(d)
		local s = sin(th)
		k1, k2 = sin((1 - t) * th) / s, sin(t * th) / s
	end
	return fromQuat(p.x + (q.x - p.x) * t, p.y + (q.y - p.y) * t, p.z + (q.z - p.z) * t,
		k1 * w1 + k2 * w2, k1 * x1 + k2 * x2, k1 * y1 + k2 * y2, k1 * z1 + k2 * z2)
end
function CFmethods.ToEulerAnglesXYZ(p)
	local ry = math.asin(math.clamp(p.c, -1, 1))
	local rx = math.atan2(-p.f, p.i)
	local rz = math.atan2(-p.b, p.a)
	return rx, ry, rz
end
CFmethods.ToOrientation = function(p)
	local rx = math.asin(math.clamp(-p.f, -1, 1))
	local ry = math.atan2(p.c, p.i)
	local rz = math.atan2(p.d, p.e)
	return rx, ry, rz
end
function CFmethods.ToAxisAngle(p)
	local w, x, y, z = toQuat(p)
	local s = sqrt(math.max(0, 1 - w * w))
	local ang = 2 * math.acos(math.clamp(w, -1, 1))
	if s < 1e-9 then
		return vec(1, 0, 0), 0
	end
	return vec(x / s, y / s, z / s), ang
end
function CFmethods.Orthonormalize(p)
	local w, x, y, z = toQuat(p)
	return fromQuat(p.x, p.y, p.z, w, x, y, z)
end

CFmt.__index = function(p, k)
	if k == "Position" or k == "p" then
		return vec(p.x, p.y, p.z)
	elseif k == "Rotation" then
		return cf(0, 0, 0, p.a, p.b, p.c, p.d, p.e, p.f, p.g, p.h, p.i)
	elseif k == "X" then
		return p.x
	elseif k == "Y" then
		return p.y
	elseif k == "Z" then
		return p.z
	elseif k == "LookVector" or k == "lookVector" then
		return vec(-p.c, -p.f, -p.i)
	elseif k == "RightVector" or k == "XVector" then
		return vec(p.a, p.d, p.g)
	elseif k == "UpVector" or k == "YVector" then
		return vec(p.b, p.e, p.h)
	elseif k == "ZVector" then
		return vec(p.c, p.f, p.i)
	end
	return CFmethods[k]
end
CFmt.__mul = function(p, q)
	if getmetatable(q) == V3mt then
		return CFmethods.PointToWorldSpace(p, q)
	end
	return mul(p, q)
end
CFmt.__add = function(p, v)
	return cf(p.x + v.X, p.y + v.Y, p.z + v.Z, p.a, p.b, p.c, p.d, p.e, p.f, p.g, p.h, p.i)
end
CFmt.__sub = function(p, v)
	return cf(p.x - v.X, p.y - v.Y, p.z - v.Z, p.a, p.b, p.c, p.d, p.e, p.f, p.g, p.h, p.i)
end
CFmt.__eq = function(p, q)
	return p.x == q.x and p.y == q.y and p.z == q.z and p.a == q.a and p.b == q.b and p.c == q.c and p.d == q.d and p.e == q.e and p.f == q.f and p.g == q.g and p.h == q.h and p.i == q.i
end
CFmt.__tostring = function(p)
	return string.format("%g, %g, %g, %g, %g, %g, %g, %g, %g, %g, %g, %g", p.x, p.y, p.z, p.a, p.b, p.c, p.d, p.e, p.f, p.g, p.h, p.i)
end

local function rx(t)
	local c, s = cos(t), sin(t)
	return cf(0, 0, 0, 1, 0, 0, 0, c, -s, 0, s, c)
end
local function ry(t)
	local c, s = cos(t), sin(t)
	return cf(0, 0, 0, c, 0, s, 0, 1, 0, -s, 0, c)
end
local function rz(t)
	local c, s = cos(t), sin(t)
	return cf(0, 0, 0, c, -s, 0, s, c, 0, 0, 0, 1)
end

function CF.new(...)
	local n = select("#", ...)
	local a1, a2, a3 = ...
	if n == 0 then
		return cf(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1)
	elseif n == 1 then
		return cf(a1.X, a1.Y, a1.Z, 1, 0, 0, 0, 1, 0, 0, 0, 1)
	elseif n == 2 then
		local eye, at = a1, a2
		local look = (at - eye).Unit
		local right = look:Cross(vec(0, 1, 0))
		if right.Magnitude < 1e-6 then
			right = vec(1, 0, 0)
		end
		right = right.Unit
		local up = right:Cross(look)
		return cf(eye.X, eye.Y, eye.Z, right.X, up.X, -look.X, right.Y, up.Y, -look.Y, right.Z, up.Z, -look.Z)
	elseif n == 3 then
		return cf(a1, a2, a3, 1, 0, 0, 0, 1, 0, 0, 0, 1)
	elseif n == 7 then
		local x, y, z, qx, qy, qz, qw = ...
		return fromQuat(x, y, z, qw, qx, qy, qz)
	end
	return cf(...)
end
function CF.Angles(x, y, z)
	return mul(mul(rx(x), ry(y)), rz(z))
end
CF.fromEulerAnglesXYZ = CF.Angles
function CF.fromEulerAnglesYXZ(x, y, z)
	return mul(mul(ry(y), rx(x)), rz(z))
end
CF.fromOrientation = CF.fromEulerAnglesYXZ
function CF.fromAxisAngle(axis, t)
	local u = axis.Unit
	local c, s = cos(t), sin(t)
	local k = 1 - c
	local x, y, z = u.X, u.Y, u.Z
	return cf(0, 0, 0,
		c + x * x * k, x * y * k - z * s, x * z * k + y * s,
		y * x * k + z * s, c + y * y * k, y * z * k - x * s,
		z * x * k - y * s, z * y * k + x * s, c + z * z * k)
end
function CF.lookAt(eye, at)
	return CF.new(eye, at)
end
function CF.fromMatrix(pos, vx, vy, vz)
	vz = vz or vx:Cross(vy)
	return cf(pos.X, pos.Y, pos.Z, vx.X, vy.X, vz.X, vx.Y, vy.Y, vz.Y, vx.Z, vy.Z, vz.Z)
end
CF.identity = CF.new()

local nativeTypeof = typeof
local function robloxTypeof(v)
	local mt = type(v) == "table" and getmetatable(v)
	if mt == V3mt then
		return "Vector3"
	elseif mt == CFmt then
		return "CFrame"
	end
	return nativeTypeof(v)
end

local function signal()
	return {
		Connect = function(_, f)
			return {Disconnect = function() end, Connected = true}
		end,
		Once = function(_, f)
			return {Disconnect = function() end}
		end,
		Wait = function() end,
	}
end

local services = {
	RunService = {PreSimulation = signal(), Heartbeat = signal(), RenderStepped = signal(), Stepped = signal(), PostSimulation = signal(), PreAnimation = signal()},
	TweenService = {Create = function() return {Play = function() end, Completed = signal()} end},
}

local game = {
	GetService = function(_, name)
		local s = services[name]
		if not s then
			s = {}
			services[name] = s
		end
		return s
	end,
}

local Enum = setmetatable({}, {
	__index = function(_, group)
		return setmetatable({}, {__index = function(_, item) return group .. "." .. item end})
	end,
})

local function newInstance(class)
	local inst = {ClassName = class, Name = class, children = {}, attrs = {}}
	function inst:IsA(c)
		return self.ClassName == c
	end
	function inst:GetChildren()
		return self.children
	end
	function inst:GetDescendants()
		return self.children
	end
	function inst:GetAttribute(k)
		return self.attrs[k]
	end
	function inst:SetAttribute(k, v)
		self.attrs[k] = v
	end
	return inst
end

local task = {
	spawn = function(f, ...)
		return f(...)
	end,
	defer = function(f, ...)
		return f(...)
	end,
	delay = function(_, f, ...)
		return f(...)
	end,
	wait = function(t)
		return t or 0
	end,
}

return {
	Vector3 = V3,
	CFrame = CF,
	typeof = robloxTypeof,
	game = game,
	Enum = Enum,
	Instance = {new = newInstance},
	task = task,
}
