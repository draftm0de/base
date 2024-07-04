ARG IMAGE_NAME
FROM ${IMAGE_NAME}

# Set timezone
ARG TIME_ZONE
ENV TZ=${TIME_ZONE}
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
