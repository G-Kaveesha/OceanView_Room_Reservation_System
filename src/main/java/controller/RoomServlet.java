package controller;

import dao.RoomDAO;
import model.Room;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import jakarta.servlet.http.Part;

import java.io.File;
import java.io.IOException;
import java.nio.file.Paths;
import java.util.List;

@WebServlet("/RoomServlet")
@MultipartConfig(
        fileSizeThreshold = 1024 * 1024,      
        maxFileSize = 1024 * 1024 * 5,        
        maxRequestSize = 1024 * 1024 * 10     
)
public class RoomServlet extends HttpServlet {

    private final RoomDAO roomDAO = new RoomDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate"); 
        response.setHeader("Pragma", "no-cache");
        response.setDateHeader("Expires", 0);

        // Manager-only
        HttpSession session = request.getSession(false);
        String role = (session == null) ? null : (String) session.getAttribute("userRole");
        if (role == null || !"MANAGER".equalsIgnoreCase(role)) {
            response.sendRedirect(request.getContextPath() + "/Views/login.jsp");
            return;
        }

        try {
            List<Room> rooms = roomDAO.getAllRooms();
            request.setAttribute("rooms", rooms);

            String msg = (String) session.getAttribute("flashMsg");
            String msgType = (String) session.getAttribute("flashType");
            if (msg != null) {
                request.setAttribute("flashMsg", msg);
                request.setAttribute("flashType", msgType);
                session.removeAttribute("flashMsg");
                session.removeAttribute("flashType");
            }

            request.getRequestDispatcher("/Views/manager/room.jsp").forward(request, response);

        } catch (Exception e) {
            throw new ServletException(e);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        String role = (session == null) ? null : (String) session.getAttribute("userRole");
        if (role == null || !"MANAGER".equalsIgnoreCase(role)) {
            response.sendRedirect(request.getContextPath() + "/Views/login.jsp");
            return;
        }

        String action = request.getParameter("action");
        if (action == null) action = "";

        switch (action.toLowerCase()) {
            case "add":
                handleAdd(request, response);
                break;
            case "update":
                handleUpdate(request, response);
                break;
            case "delete":
                handleDelete(request, response);
                break;
            default:
                response.sendRedirect(request.getContextPath() + "/RoomServlet");
        }
    }

    private void handleAdd(HttpServletRequest request, HttpServletResponse response)
            throws IOException, ServletException {

        HttpSession session = request.getSession();

        try {
            String roomNumber = request.getParameter("roomNumber");
            String floorNoStr = request.getParameter("floorNo");
            String typeName = request.getParameter("typeName");
            String capacityStr = request.getParameter("capacity");
            String nightlyRateStr = request.getParameter("nightlyRate");
            String isActiveStr = request.getParameter("isActive");
            String description = request.getParameter("description");
            String notes = request.getParameter("notes");

            // Basic validation
            if (roomNumber == null || roomNumber.trim().isEmpty()) {
                flash(session, "Room Number is required.", "danger");
                response.sendRedirect(request.getContextPath() + "/RoomServlet");
                return;
            }

            if (roomDAO.roomNumberExists(roomNumber.trim())) {
                flash(session, "Room Number already exists. Please use a unique number.", "warning");
                response.sendRedirect(request.getContextPath() + "/RoomServlet");
                return;
            }

            int capacity = Integer.parseInt(capacityStr);
            double nightlyRate = Double.parseDouble(nightlyRateStr);
            int isActive = Integer.parseInt(isActiveStr);

            Integer floorNo = null;
            if (floorNoStr != null && !floorNoStr.trim().isEmpty()) {
                floorNo = Integer.parseInt(floorNoStr);
            }

            String savedFileName = null;
            Part imagePart = request.getPart("roomImage");
            if (imagePart != null && imagePart.getSize() > 0) {
                String submitted = Paths.get(imagePart.getSubmittedFileName()).getFileName().toString();
                String ext = "";
                int dot = submitted.lastIndexOf('.');
                if (dot >= 0) ext = submitted.substring(dot);

                String uploadDir = getServletContext().getRealPath("/images/rooms");
                File dir = new File(uploadDir);
                if (!dir.exists()) dir.mkdirs();

                String stored = "room_" + System.currentTimeMillis() + ext;
                imagePart.write(uploadDir + File.separator + stored);

                savedFileName = "images/rooms/" + stored;
            }

            Room r = new Room();
            r.setRoomNumber(roomNumber.trim());
            r.setFloorNo(floorNo);
            r.setTypeName(typeName);
            r.setCapacity(capacity);
            r.setNightlyRate(nightlyRate);
            r.setIsActive(isActive);
            r.setDescription(description);
            r.setNotes(notes);
            r.setRoomImage(savedFileName);

            boolean ok = roomDAO.addRoom(r);
            if (ok) flash(session, "Room created successfully!", "success");
            else flash(session, "Failed to create room. Try again.", "danger");

            response.sendRedirect(request.getContextPath() + "/RoomServlet");

        } catch (Exception ex) {
            ex.printStackTrace();
            flash(session, "Error: " + ex.getMessage(), "danger");
            response.sendRedirect(request.getContextPath() + "/RoomServlet");
        }
    }

    private void handleUpdate(HttpServletRequest request, HttpServletResponse response)
            throws IOException, ServletException {

        HttpSession session = request.getSession();

        try {
            int roomId = Integer.parseInt(request.getParameter("roomId"));

            String roomNumber = request.getParameter("roomNumber");
            String floorNoStr = request.getParameter("floorNo");
            String typeName = request.getParameter("typeName");
            String capacityStr = request.getParameter("capacity");
            String nightlyRateStr = request.getParameter("nightlyRate");
            String isActiveStr = request.getParameter("isActive");
            String description = request.getParameter("description");
            String notes = request.getParameter("notes");

            if (roomNumber == null || roomNumber.trim().isEmpty()) {
                flash(session, "Room Number is required.", "danger");
                response.sendRedirect(request.getContextPath() + "/RoomServlet");
                return;
            }

            if (roomDAO.roomNumberExistsOtherThan(roomNumber.trim(), roomId)) {
                flash(session, "Room Number already exists. Please use a unique number.", "warning");
                response.sendRedirect(request.getContextPath() + "/RoomServlet");
                return;
            }

            int capacity = Integer.parseInt(capacityStr);
            double nightlyRate = Double.parseDouble(nightlyRateStr);
            int isActive = Integer.parseInt(isActiveStr);

            Integer floorNo = null;
            if (floorNoStr != null && !floorNoStr.trim().isEmpty()) {
                floorNo = Integer.parseInt(floorNoStr);
            }

            String newImagePath = null;
            Part imagePart = request.getPart("roomImageEdit");
            if (imagePart != null && imagePart.getSize() > 0) {
                String submitted = Paths.get(imagePart.getSubmittedFileName()).getFileName().toString();
                String ext = "";
                int dot = submitted.lastIndexOf('.');
                if (dot >= 0) ext = submitted.substring(dot);

                String uploadDir = getServletContext().getRealPath("/images/rooms");
                File dir = new File(uploadDir);
                if (!dir.exists()) dir.mkdirs();

                String stored = "room_" + System.currentTimeMillis() + ext;
                imagePart.write(uploadDir + File.separator + stored);

                newImagePath = "images/rooms/" + stored;
            }

            Room r = new Room();
            r.setRoomId(roomId);
            r.setRoomNumber(roomNumber.trim());
            r.setFloorNo(floorNo);
            r.setTypeName(typeName);
            r.setCapacity(capacity);
            r.setNightlyRate(nightlyRate);
            r.setIsActive(isActive);
            r.setDescription(description);
            r.setNotes(notes);

            boolean ok = roomDAO.updateRoomManager(r, newImagePath);

            if (ok) flash(session, "Room updated successfully!", "success");
            else flash(session, "Failed to update room.", "danger");

            response.sendRedirect(request.getContextPath() + "/RoomServlet");

        } catch (Exception ex) {
            ex.printStackTrace();
            flash(session, "Error: " + ex.getMessage(), "danger");
            response.sendRedirect(request.getContextPath() + "/RoomServlet");
        }
    }

    private void handleDelete(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        HttpSession session = request.getSession();

        try {
            int roomId = Integer.parseInt(request.getParameter("roomId"));
            boolean ok = roomDAO.deleteRoom(roomId);

            if (ok) flash(session, "Room deleted successfully!", "success");
            else flash(session, "Room not found or already deleted.", "warning");

            response.sendRedirect(request.getContextPath() + "/RoomServlet");

        } catch (Exception ex) {
            ex.printStackTrace();
            flash(session, "Error: " + ex.getMessage(), "danger");
            response.sendRedirect(request.getContextPath() + "/RoomServlet");
        }
    }

    private void flash(HttpSession session, String msg, String type) {
        session.setAttribute("flashMsg", msg);
        session.setAttribute("flashType", type); 
    }
}
