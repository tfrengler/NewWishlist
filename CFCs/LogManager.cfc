<cfcomponent output="false" modifier="final" hint="A lean, mean, simple logging class. Logs simple values to a single txt-file which is rotated based on day. Can also log complex values which are logged as individual html-files with a cfdump-inside. Utilizes Java's BufferedWriter to prevent the disk from being hammered by repeated calls. NOTE: Don't forget to call dispose() once you are done, or the simple-logfile will remain locked by Tomcat!" >

    <!--- PROPERTIES --->
    <cfset variables.absolutePathToLogFolder = "" />
    <cfset variables.eventTypes = ["CRITICAL","INFO","WARNING"] />
    <cfset variables.simpleLogFileHandle = null /> <!--- java.io.BufferedWriter, wrapping a java.io.FileWriter --->
    <cfset variables.lastLogFileCheck = getTickCount() />
    <cfset variables.logFileCheckInterval = 60000 /> <!--- ms --->
    <cfset variables.flushTimeThreshold = 10000 /> <!--- ms --->
    <cfset variables.lastFlush = 0 />
    <cfset variables.simpleLogFileName = function() {return "LOG_" & LSDateFormat(now(), "yyyy_mm_dd") & ".txt"} />
    <cfset variables.complexLogFileName = function() {return createGUID() & "_" & LSDateTimeFormat(now(), "yyyy_mm_dd_HH-nn-ss") & ".html"} />

    <!--- PUBLIC --->
    <cffunction name="init" returntype="LogManager" access="public" hint="Constructor" >
        <cfargument name="absolutePathToLogFolder" type="string" required="true" />

        <cfset variables.absolutePathToLogFolder = variables.normalizePath(path=(arguments.absolutePathToLogFolder & "/")) />

        <cfif NOT directoryExists(variables.absolutePathToLogFolder) >
            <cfthrow message="Error initializing EventManager" detail="The folder from argument 'absolutePathToLogFolder' does not exist (#variables.absolutePathToLogFolder#)" />
        </cfif>

        <cfset var fileWriter = createObject("java", "java.io.FileWriter").init(variables.absolutePathToLogFolder & variables.simpleLogFileName(), true) />
        <cfset variables.simpleLogFileHandle = createObject("java", "java.io.BufferedWriter").init(fileWriter) />

        <cfreturn this />
    </cffunction>

    <cffunction name="dispose" returntype="void" access="public" hint="Releases the underlying filehandle that the simple-log uses" >
        <cftry>
            <cfset variables.simpleLogFileHandle.close() />
            <cfcatch type="java.io.IOException">
                <!--- Nothing, just in case the handle is invalid --->
            </cfcatch>
        </cftry>
    </cffunction>

    <cffunction name="flush" returntype="void" access="public" hint="Flushes any text still in the simple-log's buffer to disk. NOTE: This is done automatically by dispose()" >
        <cftry>
            <cfset variables.simpleLogFileHandle.flush() />
            <cfcatch type="java.io.IOException">
                <!--- Nothing, just in case the handle is invalid --->
            </cfcatch>
        </cftry>
    </cffunction>

    <cffunction name="logSimple" returntype="void" access="public" >
        <cfargument name="data" type="string" required="true" />
        <cfargument name="type" type="string" required="false" default="INFO" />
        <cfargument name="calledBy" type="string" required="false" default="UNKNOWN" />

        <cfif arrayFind(variables.eventTypes, arguments.type) IS 0 >
            <cfthrow message="Error logging simple output" detail="Argument 'type' is invalid: #arguments.type# | Valid types are: #arrayToList(variables.eventTypes)#" />
        </cfif>

        <cfset var logEntry = "#variables.getOutputPrependData(calledBy=arguments.calledBy)# - [#arguments.type#]: #trim(data)#" />
        <cfset variables.appendLine(output=logEntry) />
    </cffunction>

    <cffunction name="logComplex" returntype="void" access="public" >
        <cfargument name="data" type="any" required="true" />
        <cfargument name="type" type="string" required="false" default="INFO" />
        <cfargument name="calledBy" type="string" required="false" default="UNKNOWN" />

        <cfif arrayFind(variables.eventTypes, arguments.type) IS 0 >
            <cfthrow message="Error logging complex output" detail="Argument 'type' is invalid: #arguments.type# | Valid types are: #arrayToList(variables.eventTypes)#" />
        </cfif>

        <cfset var logEntry = "" />

        <cfsavecontent variable="logEntry" >
        <cfoutput>
            <section class="LogEntry" >
                <h1 style="#trim(variables.getHTMLStylingForLogType(type=arguments.type))#" >#trim(variables.getOutputPrependData(calledBy=arguments.calledBy))#:</h1>
                <p>
                    <cfdump var=#arguments.data# />
                </p>
            </section>
        </cfoutput>
        </cfsavecontent>

        <cfset logEntry = reReplace(logEntry, "<script[\s\S\n]+?/script>", "", "ALL") />

        <cfset var logFileHandle = variables.getLogFileHandle(true) />
        <cfset fileWrite(logFileHandle, logEntry, "UTF-8") />
        <cfset variables.logSimple("Complex type logged: #logFileHandle.getName()#", "INFO", "LogManager") />
    </cffunction>

    <!--- PRIVATE --->
    <cffunction name="normalizePath" returntype="string" access="private" hint="Normalizes any path to a UNIX-friendly path with forward slashes as delimiters" >
        <cfargument name="path" type="string" required="true" />
        <!--- We do two passes to catch any double-forward slashes that are created in the first pass --->
        <cfset arguments.path = reReplace(arguments.path, "/{2,}|\\{1,}", "/", "ALL") />
        <cfreturn reReplace(arguments.path, "/{2,}|\\{1,}", "/", "ALL") />
    </cffunction>

    <cffunction name="appendLine" returntype="void" access="private" hint="Appends text to the simple log-file. Text may not appear immediately in the file due to buffering. Flushing is guaranteed to happen when this is called based on the flush time threshold." >
        <cfargument name="output" type="string" required="true" />

        <cfset var fileHandle = variables.getLogFileHandle(complex=false) />
        <cfset fileHandle.write(arguments.output) />
        <cfset fileHandle.newLine() />

        <cfif getTickCount() - variables.lastFlush GT variables.flushTimeThreshold >
            <cfset variables.flush() />
            <cfset variables.lastFlush = getTickCount() />
        </cfif> 
    </cffunction>

    <cffunction name="getLogFileHandle" returntype="any" access="private" >
        <cfargument name="complex" type="boolean" required="false" default="false" />

        <cfif arguments.complex >
            <cfreturn createObject("java", "java.io.File").init(variables.absolutePathToLogFolder & variables.complexLogFileName()) >
        </cfif>

        <cfset var logFileName = variables.simpleLogFileName() >

        <cfif   getTickCount() - variables.lastLogFileCheck GT variables.logFileCheckInterval 
                AND getFileInfo(variables.absolutePathToLogFolder & logFileName).name NEQ logFileName >

            <cfset variables.appendLine(output="#getOutputPrependData("LogManager")# - Logfile CLOSED, rotating to file: #logFileName#") />
            <cfset variables.dispose() />
            <cfset variables.lastLogFileCheck = getTickCount() />

            <cfset var fileWriter = createObject("java", "java.io.FileWriter").init(variables.absolutePathToLogFolder & logFileName, true) />
            <cfset variables.simpleLogFileHandle = createObject("java", "java.io.BufferedWriter").init(fileWriter) />
        </cfif>

        <cfreturn variables.simpleLogFileHandle />
    </cffunction>

    <cffunction name="getHTMLStylingForLogType" returntype="string" access="private" >
        <cfargument name="type" type="string" required="false" default="INFO" />
        
        <cfset var HTMLStyleString = "" />

        <cfswitch expression=#arguments.type# >
            <cfcase value="WARNING" >
                <cfset HTMLStyleString = "background-color: orange; color: white;" />
            </cfcase>

            <cfcase value="CRITICAL" >
                <cfset HTMLStyleString = "background-color: red; color: white;" />
            </cfcase>

            <cfdefaultcase>
                <cfset HTMLStyleString = "background-color: green; color: white;" />
            </cfdefaultcase>
        </cfswitch>

        <cfreturn HTMLStyleString />
    </cffunction>

    <cffunction name="getOutputPrependData" returntype="string" access="private" >
        <cfargument name="calledBy" type="string" required="false" default="UNKNOWN" />

        <cfreturn "#LSDateTimeFormat(now(), "[dd/mm/yyyy - HH:nn:ss]")# - [#arguments.calledBy#]" />
    </cffunction>
</cfcomponent>