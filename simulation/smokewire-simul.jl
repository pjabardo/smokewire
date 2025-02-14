### A Pluto.jl notebook ###
# v0.20.4

using Markdown
using InteractiveUtils

# This Pluto notebook uses @bind for interactivity. When running this notebook outside of Pluto, the following 'mock version' of @bind gives bound variables a default value (instead of an error).
macro bind(def, element)
    #! format: off
    quote
        local iv = try Base.loaded_modules[Base.PkgId(Base.UUID("6e696c72-6542-2067-7265-42206c756150"), "AbstractPlutoDingetjes")].Bonds.initial_value catch; b -> missing; end
        local el = $(esc(element))
        global $(esc(def)) = Core.applicable(Base.get, el) ? Base.get(el) : iv(el)
        el
    end
    #! format: on
end

# ╔═╡ b1e98b56-9b87-11ef-0291-31d1e88ab4b0
md"""
# Gerador de fumaça

"""

# ╔═╡ 711e60ee-f311-45b5-8b0f-bd1b3c1d8aae
import PlutoUI

# ╔═╡ 3baf40ba-7f9d-4c9a-957f-beab078aea11
# Nusselt para cilindro
function nucyl(Re, Pr=0.7, Prs=Pr)
	if Pr < 20
		n = 0.37
	else
		n = 0.36
	end
	
	if Re < 40
		C = 0.75
		m = 0.4
	elseif Re < 1000
		C = 0.51
		m = 0.5
	elseif Re < 2e5
		C = 0.26
		m = 0.6
	else
		C = 0.076
		m = 0.7
	end

	return C * Re^m * Pr^n * (Pr/Prs)^0.25
		
end

# ╔═╡ fe1dfa04-66dc-4185-971a-edbe93aafdbc
begin
	# Propriedades do fio (Nicromo e aço inox)
	resistivity = Dict("NiCr"=>110e-8, "304L"=>72e-8) # Ωm
	heatcond = Dict("NiCr"=>13.0, "304L"=>16.2)  # W/mK
	density = Dict("NiCr"=>8.3e3, "304L"=>7.93e3)  # kg/m³
	tempcoef = Dict("NiCr"=>0.0004, "304L"=>0.001) # 1/K
	specheat = Dict("NiCr"=>480.0, "304L"=>490.0) # J/kg.K
end

# ╔═╡ c93133c6-c836-4125-a9fc-9fb1c9f97680
md"""
## Dados de entrada
| Propriedade | Valor | Unidade |
| ----------  | ----- | ------- |
|Material do fio | $(@bind material PlutoUI.Select(collect(keys(resistivity)))) |  |
|Diâmetro do fio | $(@bind Dmm PlutoUI.NumberField(0.01:0.01:2.0,default=0.2)) | mm |
|Comprimento do fio | $(@bind Lmm PlutoUI.NumberField(1.0:500.0,default=20.0)) | mm |
| Temperatura do fio | $(@bind Tf1 PlutoUI.Slider(30.0:10.0:800.0, show_value=true, default=300.0)) | °C |
| Velocidade do vento | $(@bind U1 PlutoUI.Slider(0.1:0.1:20.0, show_value=true, default=1.0)) | m/s |

"""

# ╔═╡ 430ec280-ef98-4f1a-b4dd-cddb0aaa99fb
# Propriedades do ar
begin
	rhoa = 1.1 # kg/m³
	cpa = 1005.0 # J/Kg.K
	ka = 0.026 # W/mK
	μ = 1.5e-3
	Pr = 0.707
end

# ╔═╡ f62ac16f-8fcf-4d38-82d2-4dab960dc027
# Condições ambientais
begin
	Pa = 93e3 # Pa
	Ta = 20.0 # °C
	U = U1 # m/s, velocidade do ar
end

# ╔═╡ e654dc1b-1bb5-44a7-a42f-9508bc97f330
# COndições do fio
begin
	L = Lmm/1000  # Comprimento
	D = Dmm/1000  # Diâmetro do fio
	Tf = Tf1 # °C
	A = π*D * L # Área exposta
	As = π*D^2/4 # Área da seção transversal
end
	

# ╔═╡ 9769323c-7413-49b7-9144-15cfe8041b18
# Propriedades do fio
begin
	ρ = resistivity[material]
	k = heatcond[material]
	rho = density[material]
	α = tempcoef[material]
	cp = specheat[material]
end

# ╔═╡ 0eb4fae6-9307-4965-84b9-2879fdb1879b
# Convecção natural
h = let
	Re = rhoa * U * D / μ
	Nu = nucyl(Re,Pr)
	ka * Nu / D
end

# ╔═╡ bae1b1ec-5f90-4443-95bc-06ce18ced78b
R20,R = let
	# Resistência elétrica
	R20 = ρ * L / As
	R20, R20 * (1.0 + α*(Tf-Ta))
end

# ╔═╡ be39f303-d5be-4df5-8d8b-cbbb7bb9d34d
Q̇, E, I = let
	Q̇ = h*A*(Tf-Ta)
	I = sqrt(Q̇/R)
	E = R*I
	Q̇, E, I
end

# ╔═╡ 471a1636-760d-45ab-831c-b098622b1e49
md"""

# Parâmetros
| Propriedade | Valor | Unidade |
| ----------  | ----- | ------- |
| Corrente elétrica |  $(round(I,digits=2)) | A |
| Tensão elétrica |   $(round(E,digits=2)) | V |
| Resistencia a $(Ta)°C | $(round(R20, digits=2)) | Ω |
| Resistencia a $(Tf)°C | $(round(R, digits=2)) | Ω |
| Potência dissipada |  $(round(Q̇, digits=4)) | W |

"""

# ╔═╡ c8667487-3b5f-41f0-8750-2f944699ab22


# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
PlutoUI = "7f904dfe-b85e-4ff6-b463-dae2292396a8"

[compat]
PlutoUI = "~0.7.60"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.11.3"
manifest_format = "2.0"
project_hash = "8aa109ae420d50afa1101b40d1430cf3ec96e03e"

[[deps.AbstractPlutoDingetjes]]
deps = ["Pkg"]
git-tree-sha1 = "6e1d2a35f2f90a4bc7c2ed98079b2ba09c35b83a"
uuid = "6e696c72-6542-2067-7265-42206c756150"
version = "1.3.2"

[[deps.ArgTools]]
uuid = "0dad84c5-d112-42e6-8d28-ef12dabb789f"
version = "1.1.2"

[[deps.Artifacts]]
uuid = "56f22d72-fd6d-98f1-02f0-08ddc0907c33"
version = "1.11.0"

[[deps.Base64]]
uuid = "2a0f44e3-6c83-55bd-87e4-b1978d98bd5f"
version = "1.11.0"

[[deps.ColorTypes]]
deps = ["FixedPointNumbers", "Random"]
git-tree-sha1 = "b10d0b65641d57b8b4d5e234446582de5047050d"
uuid = "3da002f7-5984-5a60-b8a6-cbb66c0b333f"
version = "0.11.5"

[[deps.CompilerSupportLibraries_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "e66e0078-7015-5450-92f7-15fbd957f2ae"
version = "1.1.1+0"

[[deps.Dates]]
deps = ["Printf"]
uuid = "ade2ca70-3891-5945-98fb-dc099432e06a"
version = "1.11.0"

[[deps.Downloads]]
deps = ["ArgTools", "FileWatching", "LibCURL", "NetworkOptions"]
uuid = "f43a241f-c20a-4ad4-852c-f6b1247861c6"
version = "1.6.0"

[[deps.FileWatching]]
uuid = "7b1f6079-737a-58dc-b8bc-7a2ca5c1b5ee"
version = "1.11.0"

[[deps.FixedPointNumbers]]
deps = ["Statistics"]
git-tree-sha1 = "05882d6995ae5c12bb5f36dd2ed3f61c98cbb172"
uuid = "53c48c17-4a7d-5ca2-90c5-79b7896eea93"
version = "0.8.5"

[[deps.Hyperscript]]
deps = ["Test"]
git-tree-sha1 = "179267cfa5e712760cd43dcae385d7ea90cc25a4"
uuid = "47d2ed2b-36de-50cf-bf87-49c2cf4b8b91"
version = "0.0.5"

[[deps.HypertextLiteral]]
deps = ["Tricks"]
git-tree-sha1 = "7134810b1afce04bbc1045ca1985fbe81ce17653"
uuid = "ac1192a8-f4b3-4bfe-ba22-af5b92cd3ab2"
version = "0.9.5"

[[deps.IOCapture]]
deps = ["Logging", "Random"]
git-tree-sha1 = "b6d6bfdd7ce25b0f9b2f6b3dd56b2673a66c8770"
uuid = "b5f81e59-6552-4d32-b1f0-c071b021bf89"
version = "0.2.5"

[[deps.InteractiveUtils]]
deps = ["Markdown"]
uuid = "b77e0a4c-d291-57a0-90e8-8db25a27a240"
version = "1.11.0"

[[deps.JSON]]
deps = ["Dates", "Mmap", "Parsers", "Unicode"]
git-tree-sha1 = "31e996f0a15c7b280ba9f76636b3ff9e2ae58c9a"
uuid = "682c06a0-de6a-54ab-a142-c8b1cf79cde6"
version = "0.21.4"

[[deps.LibCURL]]
deps = ["LibCURL_jll", "MozillaCACerts_jll"]
uuid = "b27032c2-a3e7-50c8-80cd-2d36dbcbfd21"
version = "0.6.4"

[[deps.LibCURL_jll]]
deps = ["Artifacts", "LibSSH2_jll", "Libdl", "MbedTLS_jll", "Zlib_jll", "nghttp2_jll"]
uuid = "deac9b47-8bc7-5906-a0fe-35ac56dc84c0"
version = "8.6.0+0"

[[deps.LibGit2]]
deps = ["Base64", "LibGit2_jll", "NetworkOptions", "Printf", "SHA"]
uuid = "76f85450-5226-5b5a-8eaa-529ad045b433"
version = "1.11.0"

[[deps.LibGit2_jll]]
deps = ["Artifacts", "LibSSH2_jll", "Libdl", "MbedTLS_jll"]
uuid = "e37daf67-58a4-590a-8e99-b0245dd2ffc5"
version = "1.7.2+0"

[[deps.LibSSH2_jll]]
deps = ["Artifacts", "Libdl", "MbedTLS_jll"]
uuid = "29816b5a-b9ab-546f-933c-edad1886dfa8"
version = "1.11.0+1"

[[deps.Libdl]]
uuid = "8f399da3-3557-5675-b5ff-fb832c97cbdb"
version = "1.11.0"

[[deps.LinearAlgebra]]
deps = ["Libdl", "OpenBLAS_jll", "libblastrampoline_jll"]
uuid = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"
version = "1.11.0"

[[deps.Logging]]
uuid = "56ddb016-857b-54e1-b83d-db4d58db5568"
version = "1.11.0"

[[deps.MIMEs]]
git-tree-sha1 = "65f28ad4b594aebe22157d6fac869786a255b7eb"
uuid = "6c6e2e6c-3030-632d-7369-2d6c69616d65"
version = "0.1.4"

[[deps.Markdown]]
deps = ["Base64"]
uuid = "d6f4376e-aef5-505a-96c1-9c027394607a"
version = "1.11.0"

[[deps.MbedTLS_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "c8ffd9c3-330d-5841-b78e-0817d7145fa1"
version = "2.28.6+0"

[[deps.Mmap]]
uuid = "a63ad114-7e13-5084-954f-fe012c677804"
version = "1.11.0"

[[deps.MozillaCACerts_jll]]
uuid = "14a3606d-f60d-562e-9121-12d972cd8159"
version = "2023.12.12"

[[deps.NetworkOptions]]
uuid = "ca575930-c2e3-43a9-ace4-1e988b2c1908"
version = "1.2.0"

[[deps.OpenBLAS_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Libdl"]
uuid = "4536629a-c528-5b80-bd46-f80d51c5b363"
version = "0.3.27+1"

[[deps.Parsers]]
deps = ["Dates", "PrecompileTools", "UUIDs"]
git-tree-sha1 = "8489905bcdbcfac64d1daa51ca07c0d8f0283821"
uuid = "69de0a69-1ddd-5017-9359-2bf0b02dc9f0"
version = "2.8.1"

[[deps.Pkg]]
deps = ["Artifacts", "Dates", "Downloads", "FileWatching", "LibGit2", "Libdl", "Logging", "Markdown", "Printf", "Random", "SHA", "TOML", "Tar", "UUIDs", "p7zip_jll"]
uuid = "44cfe95a-1eb2-52ea-b672-e2afdf69b78f"
version = "1.11.0"

    [deps.Pkg.extensions]
    REPLExt = "REPL"

    [deps.Pkg.weakdeps]
    REPL = "3fa0cd96-eef1-5676-8a61-b3b8758bbffb"

[[deps.PlutoUI]]
deps = ["AbstractPlutoDingetjes", "Base64", "ColorTypes", "Dates", "FixedPointNumbers", "Hyperscript", "HypertextLiteral", "IOCapture", "InteractiveUtils", "JSON", "Logging", "MIMEs", "Markdown", "Random", "Reexport", "URIs", "UUIDs"]
git-tree-sha1 = "eba4810d5e6a01f612b948c9fa94f905b49087b0"
uuid = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
version = "0.7.60"

[[deps.PrecompileTools]]
deps = ["Preferences"]
git-tree-sha1 = "5aa36f7049a63a1528fe8f7c3f2113413ffd4e1f"
uuid = "aea7be01-6a6a-4083-8856-8a6e6704d82a"
version = "1.2.1"

[[deps.Preferences]]
deps = ["TOML"]
git-tree-sha1 = "9306f6085165d270f7e3db02af26a400d580f5c6"
uuid = "21216c6a-2e73-6563-6e65-726566657250"
version = "1.4.3"

[[deps.Printf]]
deps = ["Unicode"]
uuid = "de0858da-6303-5e67-8744-51eddeeeb8d7"
version = "1.11.0"

[[deps.Random]]
deps = ["SHA"]
uuid = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"
version = "1.11.0"

[[deps.Reexport]]
git-tree-sha1 = "45e428421666073eab6f2da5c9d310d99bb12f9b"
uuid = "189a3867-3050-52da-a836-e630ba90ab69"
version = "1.2.2"

[[deps.SHA]]
uuid = "ea8e919c-243c-51af-8825-aaa63cd721ce"
version = "0.7.0"

[[deps.Serialization]]
uuid = "9e88b42a-f829-5b0c-bbe9-9e923198166b"
version = "1.11.0"

[[deps.Statistics]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "ae3bb1eb3bba077cd276bc5cfc337cc65c3075c0"
uuid = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"
version = "1.11.1"

    [deps.Statistics.extensions]
    SparseArraysExt = ["SparseArrays"]

    [deps.Statistics.weakdeps]
    SparseArrays = "2f01184e-e22b-5df5-ae63-d93ebab69eaf"

[[deps.TOML]]
deps = ["Dates"]
uuid = "fa267f1f-6049-4f14-aa54-33bafae1ed76"
version = "1.0.3"

[[deps.Tar]]
deps = ["ArgTools", "SHA"]
uuid = "a4e569a6-e804-4fa4-b0f3-eef7a1d5b13e"
version = "1.10.0"

[[deps.Test]]
deps = ["InteractiveUtils", "Logging", "Random", "Serialization"]
uuid = "8dfed614-e22c-5e08-85e1-65c5234f0b40"
version = "1.11.0"

[[deps.Tricks]]
git-tree-sha1 = "7822b97e99a1672bfb1b49b668a6d46d58d8cbcb"
uuid = "410a4b4d-49e4-4fbc-ab6d-cb71b17b3775"
version = "0.1.9"

[[deps.URIs]]
git-tree-sha1 = "67db6cc7b3821e19ebe75791a9dd19c9b1188f2b"
uuid = "5c2747f8-b7ea-4ff2-ba2e-563bfd36b1d4"
version = "1.5.1"

[[deps.UUIDs]]
deps = ["Random", "SHA"]
uuid = "cf7118a7-6976-5b1a-9a39-7adc72f591a4"
version = "1.11.0"

[[deps.Unicode]]
uuid = "4ec0a83e-493e-50e2-b9ac-8f72acf5a8f5"
version = "1.11.0"

[[deps.Zlib_jll]]
deps = ["Libdl"]
uuid = "83775a58-1f1d-513f-b197-d71354ab007a"
version = "1.2.13+1"

[[deps.libblastrampoline_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850b90-86db-534c-a0d3-1478176c7d93"
version = "5.11.0+0"

[[deps.nghttp2_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850ede-7688-5339-a07c-302acd2aaf8d"
version = "1.59.0+0"

[[deps.p7zip_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "3f19e933-33d8-53b3-aaab-bd5110c3b7a0"
version = "17.4.0+2"
"""

# ╔═╡ Cell order:
# ╠═b1e98b56-9b87-11ef-0291-31d1e88ab4b0
# ╠═711e60ee-f311-45b5-8b0f-bd1b3c1d8aae
# ╟─c93133c6-c836-4125-a9fc-9fb1c9f97680
# ╟─471a1636-760d-45ab-831c-b098622b1e49
# ╠═3baf40ba-7f9d-4c9a-957f-beab078aea11
# ╠═fe1dfa04-66dc-4185-971a-edbe93aafdbc
# ╠═430ec280-ef98-4f1a-b4dd-cddb0aaa99fb
# ╠═f62ac16f-8fcf-4d38-82d2-4dab960dc027
# ╠═e654dc1b-1bb5-44a7-a42f-9508bc97f330
# ╠═9769323c-7413-49b7-9144-15cfe8041b18
# ╠═0eb4fae6-9307-4965-84b9-2879fdb1879b
# ╠═bae1b1ec-5f90-4443-95bc-06ce18ced78b
# ╠═be39f303-d5be-4df5-8d8b-cbbb7bb9d34d
# ╠═c8667487-3b5f-41f0-8750-2f944699ab22
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
