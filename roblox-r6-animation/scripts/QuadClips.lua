local P = Vector3.new

local function K(t, l, tw, s, p, e)
	return {t = t, r = {l or 0, tw or 0, s or 0}, p = p, e = e}
end

local function scaleT(keys, f)
	for _, k in keys do
		k.t *= f
	end
	return keys
end

local function mirror(clip)
	local out = {}
	for k, v in clip do
		out[k] = v
	end
	out.joints = {}
	local swap = function(n)
		if n:find("Left") then
			return (n:gsub("Left", "Right"))
		elseif n:find("Right") then
			return (n:gsub("Right", "Left"))
		end
		return n
	end
	for name, keys in clip.joints do
		local list = {}
		for _, k in keys do
			local p = k.p
			table.insert(list, {t = k.t, r = {k.r[1], -k.r[2], -k.r[3]}, p = p and P(-p.X, p.Y, p.Z), e = k.e})
		end
		out.joints[swap(name)] = list
	end
	if clip.lag then
		out.lag = {}
		for n, v in clip.lag do
			out.lag[swap(n)] = v
		end
	end
	if clip.springs then
		out.springs = {}
		for n, v in clip.springs do
			out.springs[swap(n)] = v
		end
	end
	if type(clip.life) == "table" then
		out.life = {}
		for n, v in clip.life do
			out.life[swap(n)] = v
		end
	end
	return out
end

return function(V, geo)
	local clips, gaits = {}, {}

	clips.Idle = {
		name = "Idle", length = 3.2, loop = true, curve = "spline",
		joints = {
			MainTorso = {
				K(0, -0.5, 1.2, -1.4, P(-0.018, -0.02, 0)),
				K(0.75, 2.2, 0.6, 0.2, P(-0.004, 0.035, 0.01)),
				K(1.6, -0.8, -1.2, 1.8, P(0.02, -0.025, 0)),
				K(2.4, 2.0, -0.7, 0.4, P(0.006, 0.03, 0.01)),
				K(3.2, -0.5, 1.2, -1.4, P(-0.018, -0.02, 0)),
			},
			Neck = {
				K(0, -1, 4, 0.5),
				K(0.8, 2.5, 6, 1.2),
				K(1.35, 0, 7, 1.5),
				K(1.7, -2, -8, -1.5),
				K(2.5, 2, -7, -1),
				K(3.2, -1, 4, 0.5),
			},
			Head = {
				K(0, 1, 3, 0.5),
				K(0.8, -2, 5, 2.5),
				K(1.3, 0.5, 6, 3),
				K(1.63, 2.5, -10, -3.5),
				K(1.85, 1.5, -9, -3),
				K(2.5, -1.5, -7, -2),
				K(3.2, 1, 3, 0.5),
			},
			RightEar = {
				K(0, -6, 6), K(0.95, -7, 8), K(1.07, -10, 26), K(1.3, -4, 3), K(1.55, -6.5, 7), K(3.2, -6, 6),
			},
			LeftEar = {
				K(0, -6, -6), K(2.45, -7, -7), K(2.57, -22, -11), K(2.8, -3, -4), K(3.0, -6.5, -6.5), K(3.2, -6, -6),
			},
			Jaw = {K(0, 0), K(1.6, -2), K(3.2, 0)},
		},
		lag = {Neck = 0.08},
		springs = {RightEar = "follow", LeftEar = "follow"},
		life = {MainTorso = 0.6, Neck = 1.0, Head = 1.5, Jaw = 0.5, RightEar = 2.5, LeftEar = 2.5},
	}
	gaits.Idle = {T = 3.2, v = 0, legs = {LeftArm = {fixed = true}, RightArm = {fixed = true}, LeftLeg = {fixed = true}}}

	clips.Walk = {
		name = "Walk", length = 0.4, loop = true, curve = "spline",
		joints = {
			MainTorso = {
				K(0, -2, -2, 1.2),
				K(0.1, -2.6, 0, 2, P(0.01, 0.01, 0)),
				K(0.2, -2, 2, -1.2),
				K(0.3, -2.6, 0, -2, P(-0.01, 0.01, 0)),
				K(0.4, -2, -2, 1.2),
			},
			Neck = {
				K(0, -3, 1.5), K(0.06, -5, 1), K(0.17, -1.5, -1), K(0.26, -5, -1.5), K(0.37, -1.5, 1), K(0.4, -3, 1.5),
			},
			Head = {
				K(0, 2.5, 0.8), K(0.06, 4, 0.5), K(0.17, 1, -0.5), K(0.26, 4, -0.8), K(0.37, 1, 0.5), K(0.4, 2.5, 0.8),
			},
			RightEar = {K(0, -4, 5), K(0.4, -4, 5)},
			LeftEar = {K(0, -4, -5), K(0.4, -4, -5)},
			Jaw = {K(0, 0), K(0.4, 0)},
		},
		lag = {Neck = 0.03, Head = 0.05},
		springs = {RightEar = "drag", LeftEar = "drag"},
		life = {Head = 0.6, Jaw = 0.3},
	}
	gaits.Walk = {T = 0.4, v = 8, legs = {
		LeftArm = {phase = 0, duty = 0.45, h = 0.2, fwd = -0.05, early = 0.8},
		RightArm = {phase = 0.5, duty = 0.45, h = 0.2, fwd = -0.05, early = 0.8},
		LeftLeg = {phase = 0.22, duty = 0.42, h = 0.18, fwd = 0.12},
	}}

	local sp = 0.34
	clips.Sprint = {
		name = "Sprint", length = sp, loop = true, curve = "spline",
		joints = {
			MainTorso = scaleT({
				K(0, 0, 0, 0, P(0, -0.06, 0)),
				K(0.12, 4, 0, 0, P(0, -0.1, 0)),
				K(0.26, 7, 0.5, 0, P(0, 0, 0)),
				K(0.36, 1, 0, 0, P(0, 0.1, 0)),
				K(0.48, -6, 2, 1, P(0, -0.02, 0)),
				K(0.62, -6, 0, 0.5, P(0, -0.12, 0)),
				K(0.78, -1, -1.5, -0.5, P(0, 0, 0)),
				K(0.9, 2, -0.5, 0, P(0, 0.05, 0)),
				K(1, 0, 0, 0, P(0, -0.06, 0)),
			}, sp),
			Neck = scaleT({
				K(0, -10), K(0.26, -16, -1), K(0.48, -5, 1.5), K(0.62, -5, 1), K(0.9, -12, -0.5), K(1, -10),
			}, sp),
			Head = scaleT({
				K(0, 6), K(0.26, 12), K(0.48, 2), K(0.62, 3), K(0.9, 8), K(1, 6),
			}, sp),
			RightEar = {K(0, 22, 4), K(sp, 22, 4)},
			LeftEar = {K(0, 22, -4), K(sp, 22, -4)},
			Jaw = {K(0, -3), K(sp, -3)},
		},
		lag = {Neck = 0.02, Head = 0.03},
		springs = {RightEar = "drag", LeftEar = "drag"},
	}
	gaits.Sprint = {T = sp, v = 20, legs = {
		LeftLeg = {phase = 0, duty = 0.24, h = 0.5, fwd = -0.3, early = 0.75},
		LeftArm = {phase = 0.42, duty = 0.24, h = 0.55, fwd = -0.22, early = 0.8},
		RightArm = {phase = 0.5, duty = 0.24, h = 0.55, fwd = -0.22, early = 0.8},
	}}

	clips.PivotLeft = {
		name = "PivotLeft", length = 0.4, loop = true, curve = "spline",
		joints = {
			MainTorso = {
				K(0, -2, 6, 1), K(0.1, -2.6, 7.5, 1.8), K(0.2, -2, 8, 1), K(0.3, -2.6, 6.5, 1.8), K(0.4, -2, 6, 1),
			},
			Neck = {
				K(0, -4, 15, 3), K(0.06, -6, 16, 3.5), K(0.17, -2.5, 17, 4), K(0.26, -6, 16.5, 3.5), K(0.37, -2.5, 15.5, 3), K(0.4, -4, 15, 3),
			},
			Head = {
				K(0, 3, 10, 5), K(0.06, 4.5, 11, 6), K(0.17, 2, 12, 6), K(0.26, 4.5, 11, 5.5), K(0.37, 2, 10.5, 5), K(0.4, 3, 10, 5),
			},
			RightEar = {K(0, -3, 9), K(0.4, -3, 9)},
			LeftEar = {K(0, 2, -3), K(0.4, 2, -3)},
			Jaw = {K(0, 0), K(0.4, 0)},
		},
		lag = {Neck = 0.03, Head = 0.04},
		springs = {RightEar = "drag", LeftEar = "drag"},
		life = {Head = 0.5},
	}
	gaits.PivotLeft = {T = 0.4, v = 0.5, w = math.rad(180), legs = {
		LeftArm = {phase = 0, duty = 0.45, h = 0.2, fwd = -0.05, early = 0.8},
		RightArm = {phase = 0.5, duty = 0.45, h = 0.2, fwd = -0.05, early = 0.8},
		LeftLeg = {phase = 0.22, duty = 0.42, h = 0.18, fwd = 0.12},
	}}
	clips.PivotRight = mirror(clips.PivotLeft)
	clips.PivotRight.name = "PivotRight"
	gaits.PivotRight = {T = 0.4, v = 0.5, w = -math.rad(180), legs = {
		RightArm = {phase = 0, duty = 0.45, h = 0.2, fwd = -0.05, early = 0.8},
		LeftArm = {phase = 0.5, duty = 0.45, h = 0.2, fwd = -0.05, early = 0.8},
		LeftLeg = {phase = 0.22, duty = 0.42, h = 0.18, fwd = 0.12},
	}}

	clips.RestStart = {
		name = "RestStart", length = 0.9, loop = false, curve = "spline",
		joints = {
			MainTorso = {
				K(0, 0, 0, 0), K(0.12, -3, 0, 0, P(0, 0.01, -0.04)), K(0.3, 12, 0, 0, P(0, -0.1, 0.02)),
				K(0.5, 33, 0, 0, P(0, -0.28, 0.02)), K(0.62, 39.5, 0, 0, P(0, -0.335, 0.01)), K(0.78, 37.5, 0, 0, P(0, -0.316, 0.01)),
				K(0.9, 38, 0, 0, P(0, -0.32, 0.01)),
			},
			LeftLeg = {
				K(0, 0), K(0.12, -4), K(0.3, 15), K(0.5, 44), K(0.62, 52), K(0.78, 49.5), K(0.9, 50),
			},
			Neck = {K(0, 0), K(0.12, -3), K(0.35, -8), K(0.55, -22), K(0.7, -18.5), K(0.9, -20)},
			Head = {K(0, 0), K(0.12, 2), K(0.4, -10), K(0.6, -23), K(0.75, -18.5), K(0.9, -20)},
			RightEar = {K(0, -6, 6), K(0.45, 12, 8), K(0.9, -6, 6)},
			LeftEar = {K(0, -6, -6), K(0.5, 12, -8), K(0.9, -6, -6)},
			Jaw = {K(0, 0), K(0.9, 0)},
		},
		lag = {Neck = 0.05, Head = 0.08},
		springs = {RightEar = "drag", LeftEar = "drag"},
	}
	local sitZ = -0.4
	gaits.RestStart = {T = 0.9, v = 0, tuck = 0.62, legs = {
		LeftArm = {fixed = true},
		RightArm = {fixed = true},
		LeftLeg = {path = function(t)
			local u = math.clamp((t - 0.14) / 0.46, 0, 1)
			u = u * u * (3 - 2 * u)
			return Vector3.new(0, V.FLOOR, geo.legs.LeftLeg.rest.Z + (sitZ - geo.legs.LeftLeg.rest.Z) * u), true
		end},
	}}

	clips.Rest = {
		name = "Rest", length = 3.6, loop = true, curve = "spline",
		joints = {
			MainTorso = {
				K(0, 38, 0, 0, P(0, -0.32, 0.01)), K(0.9, 39.5, 0.6, 0.5, P(0, -0.302, 0.01)), K(1.8, 37.8, -0.5, -0.3, P(0, -0.323, 0.01)),
				K(2.7, 39.2, -0.6, -0.5, P(0, -0.305, 0.01)), K(3.6, 38, 0, 0, P(0, -0.32, 0.01)),
			},
			LeftLeg = {K(0, 50), K(1.8, 50.5), K(3.6, 50)},
			Neck = {K(0, -20, 3, 0.5), K(1.0, -17.5, 6, 1), K(1.9, -20.5, 7, 1), K(2.25, -20, -7, -1), K(3.0, -18.8, -5, -0.5), K(3.6, -20, 3, 0.5)},
			Head = {K(0, -20, 2, 0.5), K(1.0, -22, 5, 2), K(1.85, -20, 6, 2.5), K(2.18, -18.5, -10, -3), K(2.4, -19, -8.5, -2.5), K(3.0, -21, -5, -1), K(3.6, -20, 2, 0.5)},
			RightEar = {K(0, -6, 6), K(2.75, -7, 8), K(2.87, -10, 26), K(3.1, -4, 3), K(3.35, -6.5, 7), K(3.6, -6, 6)},
			LeftEar = {K(0, -6, -6), K(1.25, -7, -7), K(1.37, -22, -11), K(1.6, -3, -4), K(1.8, -6.5, -6.5), K(3.6, -6, -6)},
			Jaw = {K(0, 0), K(1.8, -2), K(3.6, 0)},
		},
		lag = {Neck = 0.08},
		springs = {RightEar = "follow", LeftEar = "follow"},
		life = {MainTorso = 0.4, Neck = 1.0, Head = 1.5, Jaw = 0.5, RightEar = 2.5, LeftEar = 2.5},
	}
	gaits.Rest = {T = 3.6, v = 0, tuck = 0.62, legs = {
		LeftArm = {fixed = true},
		RightArm = {fixed = true},
		LeftLeg = {fixed = true, at = Vector3.new(0, V.FLOOR, sitZ)},
	}}

	clips.Crouch = {
		name = "Crouch", length = 1.0, loop = true, curve = "spline",
		joints = {
			MainTorso = {
				K(0, -3, -3, 1.5, P(0, -0.45, 0)), K(0.25, -3.8, 0, 2.2, P(0.01, -0.44, 0)), K(0.5, -3, 3, -1.5, P(0, -0.45, 0)),
				K(0.75, -3.8, 0, -2.2, P(-0.01, -0.44, 0)), K(1.0, -3, -3, 1.5, P(0, -0.45, 0)),
			},
			Neck = {K(0, -14, 2.5), K(0.5, -14.5, -2.5), K(1.0, -14, 2.5)},
			Head = {K(0, 12, 1), K(0.25, 12.5, 0), K(0.5, 12, -1), K(0.75, 12.5, 0), K(1.0, 12, 1)},
			RightEar = {K(0, 18, 3), K(1.0, 18, 3)},
			LeftEar = {K(0, 18, -3), K(1.0, 18, -3)},
			Jaw = {K(0, 0), K(1.0, 0)},
		},
		lag = {Neck = 0.05},
		springs = {RightEar = "follow", LeftEar = "follow"},
		life = {Head = 0.5, Neck = 0.4},
	}
	gaits.Crouch = {T = 1.0, v = 1.3, tuck = 0.7, legs = {
		LeftArm = {phase = 0, duty = 0.7, h = 0.16, fwd = -0.05},
		RightArm = {phase = 0.5, duty = 0.7, h = 0.16, fwd = -0.05},
		LeftLeg = {phase = 0.25, duty = 0.68, h = 0.14, fwd = 0.05},
	}}

	local sw = 0.4
	clips.Swim = {
		name = "Swim", length = sw, loop = true, curve = "spline",
		joints = {
			MainTorso = scaleT({
				K(0, 6, 0, 0, P(0, -0.05, 0)), K(0.25, 7.5, 1, 1.5, P(0, 0.02, 0)), K(0.5, 6, 0, 0, P(0, -0.05, 0)),
				K(0.75, 7.5, -1, -1.5, P(0, 0.02, 0)), K(1, 6, 0, 0, P(0, -0.05, 0)),
			}, sw),
			LeftArm = scaleT({
				K(0, 45, 0, 0, P(0, 0.22, 0)), K(0.24, 18, 0, 0, P(0, 0.05, 0)), K(0.5, -35), K(0.74, -8, 0, 0, P(0, 0.28, 0)), K(1, 45, 0, 0, P(0, 0.22, 0)),
			}, sw),
			RightArm = scaleT({
				K(0, -35), K(0.24, -8, 0, 0, P(0, 0.28, 0)), K(0.5, 45, 0, 0, P(0, 0.22, 0)), K(0.74, 18, 0, 0, P(0, 0.05, 0)), K(1, -35),
			}, sw),
			LeftLeg = scaleT({
				K(0, 25, 0, 0, P(0, 0.2, 0)), K(0.3, -10), K(0.5, -40), K(0.76, -15, 0, 0, P(0, 0.25, 0)), K(1, 25, 0, 0, P(0, 0.2, 0)),
			}, sw),
			Neck = scaleT({K(0, 12), K(0.25, 13.5), K(0.5, 12), K(0.75, 13.5), K(1, 12)}, sw),
			Head = scaleT({K(0, 14, 0, -1), K(0.25, 12.5, 0, 1), K(0.5, 14, 0, -1), K(0.75, 12.5, 0, 1), K(1, 14, 0, -1)}, sw),
			Jaw = scaleT({K(0, -8), K(0.5, -11), K(1, -8)}, sw),
			RightEar = {K(0, 12, 4), K(sw, 12, 4)},
			LeftEar = {K(0, 12, -4), K(sw, 12, -4)},
		},
		lag = {Neck = 0.03, Head = 0.05, LeftLeg = 0.02},
		springs = {RightEar = "drag", LeftEar = "drag"},
	}

	clips.Bite = {
		name = "Bite", length = 0.5, loop = false, curve = "spline",
		joints = {
			Neck = {
				K(0, 0), K(0.085, 16, 0, 0, P(0, 0, 0.04)), K(0.15, 21, 0, 0, P(0, 0, 0.05)), K(0.188, -6),
				K(0.215, -20, 0, 0, P(0, 0, -0.12)), K(0.26, -25, 3, 2, P(0, 0, -0.14)), K(0.32, -22, -3, -2, P(0, 0, -0.12)),
				K(0.4, -8, 0, 0, P(0, 0, -0.03)), K(0.5, 0),
			},
			Head = {
				K(0, 0), K(0.06, 10), K(0.12, 16), K(0.175, 4), K(0.21, 6), K(0.25, 2, 8, 10), K(0.31, 4, -6, -8),
				K(0.39, -1.5, 1, 1), K(0.5, 0),
			},
			Jaw = {
				K(0, 0), K(0.1, -12), K(0.165, -30), K(0.2, -34), K(0.218, 2, 0, 0, nil, "linear"), K(0.26, -5), K(0.3, 1), K(0.42, -2), K(0.5, 0),
			},
			RightEar = {K(0, -6, 6), K(0.1, 20, 10), K(0.3, 10, 5), K(0.5, -6, 6)},
			LeftEar = {K(0, -6, -6), K(0.1, 20, -10), K(0.3, 10, -5), K(0.5, -6, -6)},
		},
		springs = {RightEar = "drag", LeftEar = "drag"},
	}

	local function step(from, to, t0, t1, h)
		return function(t)
			if t <= t0 then
				return from, true
			elseif t >= t1 then
				return to, true
			end
			local u = (t - t0) / (t1 - t0)
			local p = from:Lerp(to, u * u * (3 - 2 * u))
			return Vector3.new(p.X, V.FLOOR + h * math.sin(math.pi * u), p.Z), false
		end
	end
	local rl, rr, rh = geo.legs.LeftArm.rest, geo.legs.RightArm.rest, geo.legs.LeftLeg.rest
	clips.GetUp = {
		name = "GetUp", length = 1.1, loop = false, curve = "spline",
		joints = {
			MainTorso = {
				K(0, -4, 0, 0, P(0, -0.88, 0.05)), K(0.12, -3, 0, 0, P(0, -0.86, 0.05)), K(0.4, 16, 1, 1.5, P(0, -0.55, 0.02)),
				K(0.62, 10, 0, -1, P(0, -0.3, 0)), K(0.82, -2, 0, 0, P(0, 0.03, 0)), K(0.95, 0.8, 0.5, -0.5, P(0, -0.012, 0)),
				K(1.1, -0.5, 1.2, -1.4, P(-0.018, -0.02, 0)),
			},
			Neck = {K(0, -25), K(0.1, -12, 2), K(0.35, -2, 1), K(0.6, 4, 0), K(0.85, -1, 2), K(1.1, -1, 4, 0.5)},
			Head = {
				K(0, 15), K(0.12, 6, 1), K(0.4, -4, 0), K(0.7, 2, 0), K(0.84, 1, 7, 3), K(0.92, 0, -6, -2), K(1.0, 0.5, 3, 1), K(1.1, 1, 3, 0.5),
			},
			RightEar = {K(0, 15, 3), K(0.3, 4, 6), K(0.6, -6, 6), K(0.86, -2, 14), K(0.95, -8, 0), K(1.1, -6, 6)},
			LeftEar = {K(0, 15, -3), K(0.34, 4, -6), K(0.64, -6, -6), K(0.88, -2, -14), K(0.97, -8, 0), K(1.1, -6, -6)},
			Jaw = {K(0, 0), K(0.5, -1.5), K(1.1, 0)},
		},
		lag = {Neck = 0.03},
		springs = {RightEar = "drag", LeftEar = "drag"},
		life = {Head = 0.6},
	}
	gaits.GetUp = {T = 1.1, v = 0, tuck = 0.7, legs = {
		LeftArm = {path = step(Vector3.new(rl.X, V.FLOOR, rl.Z - 1.25), Vector3.new(rl.X, V.FLOOR, rl.Z), 0.12, 0.4, 0.25)},
		RightArm = {path = step(Vector3.new(rr.X, V.FLOOR, rr.Z - 1.25), Vector3.new(rr.X, V.FLOOR, rr.Z), 0.18, 0.46, 0.25)},
		LeftLeg = {path = step(Vector3.new(0, V.FLOOR, -0.25), Vector3.new(0, V.FLOOR, rh.Z), 0.45, 0.76, 0.2)},
	}}

	return clips, gaits
end
