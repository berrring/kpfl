package com.kurs.kpfl.exception;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.validation.ConstraintViolationException;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.security.authentication.BadCredentialsException;
import org.springframework.security.core.AuthenticationException;
import org.springframework.validation.FieldError;
import org.springframework.web.HttpMediaTypeNotSupportedException;
import org.springframework.web.HttpRequestMethodNotSupportedException;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.MissingServletRequestParameterException;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;
import org.springframework.web.method.annotation.HandlerMethodValidationException;
import org.springframework.web.method.annotation.MethodArgumentTypeMismatchException;
import org.springframework.web.servlet.resource.NoResourceFoundException;
import org.springframework.http.converter.HttpMessageNotReadableException;

import java.time.Instant;
import java.util.Arrays;
import java.util.stream.Stream;
import java.util.stream.Collectors;

@RestControllerAdvice
public class GlobalExceptionHandler {

    private static final Logger log = LoggerFactory.getLogger(GlobalExceptionHandler.class);

    @ExceptionHandler(NotFoundException.class)
    public ResponseEntity<ApiErrorResponse> handleNotFound(NotFoundException ex, HttpServletRequest request) {
        return respond(HttpStatus.NOT_FOUND, safeMessage(ex.getMessage(), "Requested resource was not found."), request);
    }

    @ExceptionHandler(ConflictException.class)
    public ResponseEntity<ApiErrorResponse> handleConflict(ConflictException ex, HttpServletRequest request) {
        return respond(HttpStatus.CONFLICT, safeMessage(ex.getMessage(), "Conflict with existing data."), request);
    }

    @ExceptionHandler(DataIntegrityViolationException.class)
    public ResponseEntity<ApiErrorResponse> handleDataIntegrity(DataIntegrityViolationException ex, HttpServletRequest request) {
        return respond(HttpStatus.CONFLICT, mapDataIntegrityMessage(ex), request);
    }

    @ExceptionHandler(IllegalArgumentException.class)
    public ResponseEntity<ApiErrorResponse> handleIllegalArgument(IllegalArgumentException ex, HttpServletRequest request) {
        return respond(HttpStatus.BAD_REQUEST, safeMessage(ex.getMessage(), "Request contains invalid data."), request);
    }

    @ExceptionHandler(MethodArgumentTypeMismatchException.class)
    public ResponseEntity<ApiErrorResponse> handleTypeMismatch(MethodArgumentTypeMismatchException ex, HttpServletRequest request) {
        String parameter = ex.getName();
        Class<?> requiredType = ex.getRequiredType();

        if (requiredType != null && requiredType.isEnum()) {
            String allowedValues = Arrays.stream(requiredType.getEnumConstants())
                    .map(String::valueOf)
                    .collect(Collectors.joining(", "));
            String message = "Invalid value '%s' for parameter '%s'. Allowed values: [%s]."
                    .formatted(String.valueOf(ex.getValue()), parameter, allowedValues);
            return respond(HttpStatus.BAD_REQUEST, message, request);
        }

        String message = "Invalid value for parameter '%s'.".formatted(parameter);
        return respond(HttpStatus.BAD_REQUEST, message, request);
    }

    @ExceptionHandler(ConstraintViolationException.class)
    public ResponseEntity<ApiErrorResponse> handleConstraintViolation(ConstraintViolationException ex, HttpServletRequest request) {
        String details = ex.getConstraintViolations().stream()
                .map(v -> v.getPropertyPath() + ": " + v.getMessage())
                .collect(Collectors.joining("; "));
        return respond(HttpStatus.BAD_REQUEST, "Validation failed: " + safeMessage(details, "invalid request parameters"), request);
    }

    @ExceptionHandler(MethodArgumentNotValidException.class)
    public ResponseEntity<ApiErrorResponse> handleValidation(MethodArgumentNotValidException ex, HttpServletRequest request) {
        String details = ex.getBindingResult()
                .getFieldErrors()
                .stream()
                .map(this::toFieldMessage)
                .collect(Collectors.joining("; "));

        String message = "Validation failed: " + safeMessage(details, "invalid request payload");
        return respond(HttpStatus.BAD_REQUEST, message, request);
    }

    @ExceptionHandler(HandlerMethodValidationException.class)
    public ResponseEntity<ApiErrorResponse> handleHandlerMethodValidation(
            HandlerMethodValidationException ex,
            HttpServletRequest request
    ) {
        String parameterDetails = ex.getParameterValidationResults().stream()
                .flatMap(result -> result.getResolvableErrors().stream())
                .map(error -> error.getDefaultMessage() == null ? "Invalid request value." : error.getDefaultMessage())
                .collect(Collectors.joining("; "));

        String crossParameterDetails = ex.getCrossParameterValidationResults().stream()
                .map(error -> error.getDefaultMessage() == null ? "Invalid request value." : error.getDefaultMessage())
                .collect(Collectors.joining("; "));

        String details = Stream.of(parameterDetails, crossParameterDetails)
                .filter(value -> value != null && !value.isBlank())
                .collect(Collectors.joining("; ")); 

        return respond(HttpStatus.BAD_REQUEST, "Validation failed: " + safeMessage(details, "invalid request values"), request);
    }

    @ExceptionHandler(HttpMessageNotReadableException.class)
    public ResponseEntity<ApiErrorResponse> handleUnreadableBody(HttpMessageNotReadableException ex, HttpServletRequest request) {
        String message = "Invalid request body. Ensure JSON is valid and field types are correct.";
        return respond(HttpStatus.BAD_REQUEST, message, request);
    }

    @ExceptionHandler(MissingServletRequestParameterException.class)
    public ResponseEntity<ApiErrorResponse> handleMissingRequestParam(
            MissingServletRequestParameterException ex,
            HttpServletRequest request
    ) {
        String message = "Missing required query parameter '%s'.".formatted(ex.getParameterName());
        return respond(HttpStatus.BAD_REQUEST, message, request);
    }

    @ExceptionHandler(HttpRequestMethodNotSupportedException.class)
    public ResponseEntity<ApiErrorResponse> handleMethodNotAllowed(
            HttpRequestMethodNotSupportedException ex,
            HttpServletRequest request
    ) {
        String method = safeMessage(ex.getMethod(), "UNKNOWN");
        String message = "HTTP method '%s' is not allowed for this endpoint.".formatted(method);
        return respond(HttpStatus.METHOD_NOT_ALLOWED, message, request);
    }

    @ExceptionHandler(HttpMediaTypeNotSupportedException.class)
    public ResponseEntity<ApiErrorResponse> handleUnsupportedMediaType(
            HttpMediaTypeNotSupportedException ex,
            HttpServletRequest request
    ) {
        String mediaType = ex.getContentType() == null ? "unknown" : ex.getContentType().toString();
        String message = "Unsupported content type '%s'. Use 'application/json'.".formatted(mediaType);
        return respond(HttpStatus.UNSUPPORTED_MEDIA_TYPE, message, request);
    }

    @ExceptionHandler(NoResourceFoundException.class)
    public ResponseEntity<ApiErrorResponse> handleNoResource(NoResourceFoundException ex, HttpServletRequest request) {
        String message = "Endpoint '%s' was not found.".formatted(request.getRequestURI());
        return respond(HttpStatus.NOT_FOUND, message, request);
    }

    @ExceptionHandler(AuthenticationException.class)
    public ResponseEntity<ApiErrorResponse> handleAuth(AuthenticationException ex, HttpServletRequest request) {
        String message = ex instanceof BadCredentialsException
                ? safeMessage(ex.getMessage(), "Invalid credentials.")
                : "Authentication failed.";
        return respond(HttpStatus.UNAUTHORIZED, message, request);
    }

    @ExceptionHandler(AccessDeniedException.class)
    public ResponseEntity<ApiErrorResponse> handleForbidden(AccessDeniedException ex, HttpServletRequest request) {
        return respond(HttpStatus.FORBIDDEN, "Access denied. You do not have permission to perform this operation.", request);
    }

    @ExceptionHandler(Exception.class)
    public ResponseEntity<ApiErrorResponse> handleGeneric(Exception ex, HttpServletRequest request) {
        log.error("Unhandled exception for path {}: {}", request.getRequestURI(), ex.getMessage(), ex);
        return respond(HttpStatus.INTERNAL_SERVER_ERROR, "Unexpected server error. Please contact support.", request);
    }

    private ResponseEntity<ApiErrorResponse> respond(HttpStatus status, String message, HttpServletRequest request) {
        ApiErrorResponse body = new ApiErrorResponse(
                Instant.now(),
                status.value(),
                status.getReasonPhrase(),
                safeMessage(message, status.getReasonPhrase()),
                request.getRequestURI()
        );
        return new ResponseEntity<>(body, status);
    }

    private String toFieldMessage(FieldError error) {
        String field = safeMessage(error.getField(), "field");
        String details = safeMessage(error.getDefaultMessage(), "invalid value");
        return field + ": " + details;
    }

    private String safeMessage(String value, String fallback) {
        if (value == null || value.isBlank()) {
            return fallback;
        }
        return value;
    }

    private String mapDataIntegrityMessage(DataIntegrityViolationException ex) {
        String rawMessage = ex.getMostSpecificCause() == null ? ex.getMessage() : ex.getMostSpecificCause().getMessage();
        String source = safeMessage(rawMessage, "").toLowerCase();

        if (source.contains("uk_users_email")) {
            return "User with this email already exists.";
        }
        if (source.contains("uk_clubs_name")) {
            return "Club with this name already exists.";
        }
        if (source.contains("uk_clubs_abbr")) {
            return "Club with this abbreviation already exists.";
        }
        if (source.contains("uk_players_club_number")) {
            return "This jersey number is already used in the selected club.";
        }
        if (source.contains("duplicate")) {
            return "Duplicate value violates a uniqueness constraint.";
        }
        if (source.contains("foreign key")) {
            return "Operation failed because a referenced entity does not exist.";
        }

        return "Operation violates data integrity constraints.";
    }
}
