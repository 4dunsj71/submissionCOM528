<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"
    "http://www.w3.org/TR/html4/loose.dtd">

<%@page import="java.util.List"%>
<%@page import="java.util.ArrayList"%>
<%@page import="java.util.Set"%>
<%@page import="java.util.Date"%>
<%@page import="org.solent.com528.project.impl.webclient.WebClientObjectFactory"%>
<%@page import="org.solent.com528.project.model.service.ServiceFacade"%>
<%@page import="org.solent.com528.project.model.dao.StationDAO"%>
<%@page import="org.solent.com528.project.model.dao.TicketMachineDAO"%>
<%@page import="org.solent.com528.project.model.dto.Station"%>
<%@page import="org.solent.com528.project.model.dto.Ticket"%>


<%
    // used to place error message at top of page 
    String errorMessage = "";
    String message = "";

    // used to set html header autoload time. This automatically refreshes the page
    // Set refresh, autoload time every 20 seconds
    response.setIntHeader("Refresh", 20);

    // accessing service 
    ServiceFacade serviceFacade = (ServiceFacade) WebClientObjectFactory.getServiceFacade();
    StationDAO stationDAO = serviceFacade.getStationDAO();
    Set<Integer> zones = stationDAO.getAllZones();
    List<Station> stationList = new ArrayList<Station>();
    
   
    
    // accessing request parameters
    String actionStr = request.getParameter("action");
    String depStationName = request.getParameter("depStationName");
    String depZoneStr = request.getParameter("depZone");
    String zoneStr = request.getParameter("zone");
    
    Integer zone = 0;
    if (zoneStr != null) {
        zone = Integer.parseInt(zoneStr);
    } else {
        if (!zones.isEmpty()) {
            zone = zones.iterator().next();
        }
    }
    // return station list for zone
    if (zoneStr == null || zoneStr.isEmpty()) {
        stationList = stationDAO.findAll();
    } else {
        try {
            zone = Integer.parseInt(zoneStr);
            stationList = stationDAO.findByZone(zone);
        } catch (Exception ex) {
            errorMessage = ex.getMessage();
        }
    }

    // basic error checking before making a call
    if (actionStr == null || actionStr.isEmpty()) {
        // do nothing

    } else if ("xxx".equals(actionStr)) {
        
    } else {
        errorMessage = "ERROR: page called for unknown action";
    }   
%>

<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>Client Station List</title>
    </head>
    <body>

        <H1>Select Destination Station</H1>
        <h2>You Are Currently At: <%=depStationName%> Station</h2>
        <!-- print error message if there is one -->
        <div style="color:red;"><%=errorMessage%></div>
        <div style="color:green;"><%=message%></div>

        <p>The time is: <%= new Date().toString()%> (note page is auto refreshed every 20 seconds)</p>

        <%
            for (Integer selectZone : zones) {
        %>
        <form action="./destinationStationList.jsp" method="get">
            <input type="hidden" name="zone" value="<%= selectZone %>">
            <button type="submit" >Zone&nbsp;<%= selectZone %></button>
        </form> 
        <%
            }
        %>
        
        <table border ="1">
            <tr>
                <th>Station Name</th>
                <th>Station Zone</th>     
            </tr>
            <%
            for (Station station : stationList) {
            %>
            <tr>
                <td size="36"><%=station.getName()%></td>
                <td size="36">Zone&nbsp;<%=station.getZone()%></td>
                <td>
                    <form action="./departureTime.jsp" method="get">
                        <input type="hidden" name ="desStationName" value="<%=station.getName()%>">
                        <input type="hidden" name ="desZone" value="<%=station.getZone()%>">
                        <input type ="hidden" name="depStationName" value="<%=depStationName%>">
                        <input type="hidden" name="depZone" value="<%=depZoneStr%>">
                        <input type="hidden" name ="action" value="SelectStation">
                        <button type="submit">Select Station</button>
                    </form>
                </td>
            </tr>
            <%
                }
            %>
        </table>
        <form action="./destinationStationList.jsp" method="get" type="hidden">
            <input type ="hidden" name="stationName" value="<%=depStationName%>">
            <input type="hidden" name="zone" value="<%=zone%>">
        </form>
        
        <%
            if(actionStr != null){
                if(("stationName" +"zone" == null | "stationName" +"zone" == "" )){
                    errorMessage = "error has occurred";
                }
                else if("stationName"+"zone" != null & "stationName"+"zone" != "" ){
                    
                };
            };
        %>
    </body>
</html>

