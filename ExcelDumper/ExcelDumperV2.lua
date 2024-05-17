--love from Hiro
local obfName = "MNAPLOJNCNA"
local obfPropertyName = "JFOMGCBIBJB"

local on_error = function(error)
    CS.UnityEngine.Application.targetFrameRate = 360
    CS.UnityEngine.QualitySettings.vSyncCount = 0
    local files = io.open("./error.txt", "w")
    files:write(error)
    files:close()
end

local function getPrivateField(obj, fieldName)
    local objType = obj:GetType()
    local fieldInfo = objType:GetField(fieldName, CS.System.Reflection.BindingFlags.NonPublic | CS.System.Reflection.BindingFlags.Instance)
    return fieldInfo and fieldInfo:GetValue(obj) or nil
end

local function findPrivateIEnumeratorCurrent(obj)
    local objType = obj:GetType()
    local properties = objType:GetProperties(CS.System.Reflection.BindingFlags.NonPublic | CS.System.Reflection.BindingFlags.Instance)

    for i = 0, properties.Length - 1 do
        local property = properties[i]
        if property.Name == "System.Collections.IEnumerator.Current" then
            local propertyType = property:GetType()
            return property:GetValue(obj, nil)
        end
    end

    return nil
end

local function findPrivateMethod(obj, methodName)
    local objType = obj:GetType()
    local methodInfo = objType:GetMethod(methodName, CS.System.Reflection.BindingFlags.NonPublic | CS.System.Reflection.BindingFlags.Instance)
    return methodInfo and methodInfo:Invoke(obj, nil) or nil
end

local function processAssembly()
    local assemblies = CS.System.AppDomain.CurrentDomain:GetAssemblies()

    local targetAssemblyIndex = 88

    if targetAssemblyIndex <= #assemblies then
        local targetAssembly = assemblies[targetAssemblyIndex]
        local types = targetAssembly:GetTypes()

        for i = 0, types.Length - 1 do
            local t = types[i]
            local properties = t:GetProperties()

            for _, prop in ipairs(properties) do
                if prop.Name == "dataDict" then
                    local serializer = CS.Newtonsoft.Json.JsonSerializer()
                    serializer.Formatting = CS.Newtonsoft.Json.Formatting.Indented
                    serializer.ReferenceLoopHandling = CS.Newtonsoft.Json.ReferenceLoopHandling.Ignore
                    serializer.Converters:Add(CS.Newtonsoft.Json.Converters.StringEnumConverter())

                    local f3, a = load("return CS.RPG.GameCore." .. t.Name .. ".GetEnumerator()")
                    local enumerator = f3()

                    local f2, e2 = load("return CS.System.IO.StreamWriter(\"./Dump/test/" .. t.Name .. ".json\")")
                    local swriter = f2()
                    local jwriter = CS.Newtonsoft.Json.JsonTextWriter(swriter)

                    jwriter:WriteStartArray()

                    while enumerator:MoveNext() do
                        local currentObject = enumerator.Current
                        local isValidObject = currentObject and type(currentObject) == "userdata"

                        if isValidObject then
                            local IEnumeratorCurrent = findPrivateIEnumeratorCurrent(enumerator)

                            local swriter = CS.System.IO.StringWriter()
                            local jwriter = CS.Newtonsoft.Json.JsonTextWriter(swriter)

                            serializer:Serialize(jwriter, IEnumeratorCurrent)
                            table.insert(valuesArray, swriter:ToString())

                            jwriter:Close()
                            swriter:Close()
                        end
                    end

                    jwriter:WriteEndArray()

                    jwriter:Close()
                    swriter:Close()
                    break 
                end
            end
        end
    end
end

local function dumpDeobf(name)

    local serializer = CS.Newtonsoft.Json.JsonSerializer()
    serializer.Formatting = CS.Newtonsoft.Json.Formatting.Indented
    serializer.ReferenceLoopHandling = CS.Newtonsoft.Json.ReferenceLoopHandling.Ignore
    serializer.Converters:Add(CS.Newtonsoft.Json.Converters.StringEnumConverter())

    local f3, a = load("return CS.RPG.GameCore." .. name .. ".GetEnumerator()")
    local enumerator = f3()

    local f2, e2 = load("return CS.System.IO.StreamWriter(\"./Dump/test2/" .. name .. ".json\")")
    local swriter = f2()
    local jwriter = CS.Newtonsoft.Json.JsonTextWriter(swriter)

    jwriter:WriteStartArray()

    while enumerator:MoveNext() do
        local idk = enumerator.Current
        local IEnumeratorCurrent = findPrivateIEnumeratorCurrent(enumerator)

        serializer:Serialize(jwriter, IEnumeratorCurrent)
    end

    jwriter:WriteRaw("\n")
    jwriter:WriteEndArray()

    jwriter:Close()
    swriter:Close()
end

local function dumpObf(name)

    local serializer = CS.Newtonsoft.Json.JsonSerializer()
    serializer.Formatting = CS.Newtonsoft.Json.Formatting.Indented
    serializer.ReferenceLoopHandling = CS.Newtonsoft.Json.ReferenceLoopHandling.Ignore
    serializer.Converters:Add(CS.Newtonsoft.Json.Converters.StringEnumConverter())

    local f3, a = load("return CS." .. name .. "." .. obfName.. "()")
    local enumerator = f3()

    local f2, e2 = load("return CS.System.IO.StreamWriter(\"./Dump/test2/" .. name .. ".json\")")
    local swriter = f2()
    local jwriter = CS.Newtonsoft.Json.JsonTextWriter(swriter)

    jwriter:WriteStartArray()

    while enumerator:MoveNext() do
        local idk = enumerator.Current
        local IEnumeratorCurrent = findPrivateIEnumeratorCurrent(enumerator)

        serializer:Serialize(jwriter, IEnumeratorCurrent)
    end

    jwriter:WriteRaw("\n")
    jwriter:WriteEndArray()

    jwriter:Close()
    swriter:Close()
end

local function main1()
    local assemblies = CS.System.AppDomain.CurrentDomain:GetAssemblies()
    local assembly = assemblies[88]
    local types = assembly:GetTypes()

    for i = 0, types.Length - 1 do
        local type = types[i]
        if string.match(type.Name, "ExcelTable") then
            dumpDeobf(type.Name)
        end
        if string.match(type.Name, "ADKLGMIJHGI") then
            local fields = type:GetFields()
            for _, field in ipairs(fields) do
                on_error(field.Name)
            end
        end
    end
end

local function main()
    local assemblies = CS.System.AppDomain.CurrentDomain:GetAssemblies()
    local assembly = assemblies[88]
    local types = assembly:GetTypes()

    local typesWithProperty = {}

    for i = 0, types.Length - 1 do
        local typeName = types[i].Name

        local hasObfProperty = types[i]:GetProperty(obfPropertyName) ~= nil
        local hasProperty = types[i]:GetProperty("dataDict") ~= nil

        if hasObfProperty then
            dumpObf(typeName)
        end
        if hasProperty then
            dumpDeobf(typeName)
        end
    end
end

xpcall(main, on_error)


--windy ExcelDumperV2